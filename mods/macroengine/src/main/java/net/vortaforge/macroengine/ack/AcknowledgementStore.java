package net.vortaforge.macroengine.ack;

import com.google.gson.Gson;
import com.google.gson.GsonBuilder;
import com.google.gson.JsonSyntaxException;
import com.google.gson.reflect.TypeToken;

import java.io.IOException;
import java.io.Reader;
import java.io.Writer;
import java.lang.reflect.Type;
import java.nio.charset.StandardCharsets;
import java.nio.file.Files;
import java.nio.file.Path;
import java.nio.file.StandardCopyOption;
import java.util.LinkedHashMap;
import java.util.Locale;
import java.util.Map;
import java.util.Optional;

/**
 * The record of which packs a person has seen, at which content hash.
 *
 * <h2>The one rule</h2>
 *
 * <b>Anything this class cannot read counts as "not acknowledged".</b> A missing
 * file, a truncated file, a file with the wrong shape, a file written by a future
 * version - all of them mean "ask again", never "carry on". The failure mode of a
 * safety record must be to prompt, and prompting is cheap; the opposite failure
 * mode is silently trusting a pack whose approval nobody can find.
 *
 * <h2>Why the hash is the key</h2>
 *
 * An acknowledgement of a pack id alone would survive the pack being replaced, and
 * replacing a pack is precisely the event the record exists to catch. So the key
 * is (id, hash) and an id with an old hash is simply not a match.
 *
 * <h2>Shape on disk</h2>
 *
 * <pre>
 * {
 *   "schemaVersion": 1,
 *   "packs": {
 *     "file/mypack.zip": {
 *       "hash": "9f2c...",
 *       "acknowledgedAt": "2026-11-08T10:00:00Z",
 *       "acknowledgedBy": "tickwarden"
 *     }
 *   }
 * }
 * </pre>
 */
public final class AcknowledgementStore {
    /** Bump only when the on-disk shape changes incompatibly. */
    public static final int SCHEMA_VERSION = 1;

    private static final Gson GSON = new GsonBuilder().setPrettyPrinting().create();
    private static final Type FILE_TYPE =
            new TypeToken<FileShape>() { }.getType();

    private final Path file;
    private final Map<String, Entry> entries;

    private AcknowledgementStore(Path file, Map<String, Entry> entries) {
        this.file = file;
        this.entries = entries;
    }

    /** One acknowledgement, as recorded. */
    public record Entry(String hash, String acknowledgedAt, String acknowledgedBy) {
    }

    /** On-disk wrapper. Kept separate so a future field cannot collide with a pack id. */
    private static final class FileShape {
        int schemaVersion = SCHEMA_VERSION;
        Map<String, Entry> packs = new LinkedHashMap<>();
    }

    /**
     * Load, or start empty.
     *
     * <p>Never throws for a bad file. A corrupt record is a reason to ask the
     * person again, not a reason to stop the game from starting - the alternative
     * would let a byte of disk corruption take a world offline.
     */
    public static AcknowledgementStore load(Path file) {
        if (!Files.isRegularFile(file)) {
            return new AcknowledgementStore(file, new LinkedHashMap<>());
        }
        try (Reader reader = Files.newBufferedReader(file, StandardCharsets.UTF_8)) {
            FileShape shape = GSON.fromJson(reader, FILE_TYPE);
            if (shape == null || shape.packs == null) {
                return new AcknowledgementStore(file, new LinkedHashMap<>());
            }
            if (shape.schemaVersion != SCHEMA_VERSION) {
                // A different schema is not something to guess at.
                return new AcknowledgementStore(file, new LinkedHashMap<>());
            }
            Map<String, Entry> clean = new LinkedHashMap<>();
            for (Map.Entry<String, Entry> e : shape.packs.entrySet()) {
                Entry v = e.getValue();
                if (v != null && v.hash() != null && !v.hash().isBlank()) {
                    clean.put(normalise(e.getKey()), v);
                }
            }
            return new AcknowledgementStore(file, clean);
        } catch (IOException | JsonSyntaxException | RuntimeException e) {
            // Unreadable or malformed: fail closed by knowing nothing.
            return new AcknowledgementStore(file, new LinkedHashMap<>());
        }
    }

    /** True when this exact id-at-this-hash has been acknowledged. */
    public boolean isAcknowledged(String packId, String hash) {
        Entry entry = entries.get(normalise(packId));
        if (entry == null || hash == null) {
            return false;
        }
        return entry.hash().equalsIgnoreCase(hash);
    }

    /** The recorded entry, for showing "you approved this on ...". */
    public Optional<Entry> entryFor(String packId) {
        return Optional.ofNullable(entries.get(normalise(packId)));
    }

    /**
     * Record an acknowledgement and write the file.
     *
     * <p>The write is a temp-file-and-rename so an interrupted save cannot leave a
     * half-written record that the next load would read as "nothing acknowledged".
     *
     * @throws IOException if the record cannot be written. The caller decides what
     *                     to do; this class will not silently pretend it saved.
     */
    public void acknowledge(String packId, String hash, String by, String at) throws IOException {
        entries.put(normalise(packId), new Entry(hash, at, by));
        save();
    }

    /** Drop every entry. Used by a "forget all" operator command. */
    public void clear() throws IOException {
        entries.clear();
        save();
    }

    public int size() {
        return entries.size();
    }

    /** Where this store reads and writes. */
    public Path path() {
        return file;
    }

    private void save() throws IOException {
        FileShape shape = new FileShape();
        shape.packs = new LinkedHashMap<>(entries);
        Path parent = file.getParent();
        if (parent != null) {
            Files.createDirectories(parent);
        }
        Path temp = file.resolveSibling(file.getFileName() + ".tmp");
        try (Writer writer = Files.newBufferedWriter(temp, StandardCharsets.UTF_8)) {
            GSON.toJson(shape, writer);
        }
        try {
            Files.move(temp, file, StandardCopyOption.REPLACE_EXISTING, StandardCopyOption.ATOMIC_MOVE);
        } catch (java.nio.file.AtomicMoveNotSupportedException e) {
            // Some filesystems cannot move atomically. A plain replace is still
            // better than leaving the temp file: the record stays complete either
            // way, only the crash window widens.
            Files.move(temp, file, StandardCopyOption.REPLACE_EXISTING);
        }
    }

    private static String normalise(String packId) {
        return packId == null ? "" : packId.trim().toLowerCase(Locale.ROOT).replace('\\', '/');
    }
}
