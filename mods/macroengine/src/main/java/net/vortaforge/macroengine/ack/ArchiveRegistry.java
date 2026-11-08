package net.vortaforge.macroengine.ack;

import com.google.gson.Gson;
import com.google.gson.reflect.TypeToken;

import java.io.IOException;
import java.io.InputStream;
import java.io.InputStreamReader;
import java.io.Reader;
import java.lang.reflect.Type;
import java.nio.charset.StandardCharsets;
import java.util.HashMap;
import java.util.List;
import java.util.Locale;
import java.util.Map;
import java.util.Optional;

/**
 * Which packs this project has retired, so the warning can be more specific.
 *
 * <h2>Why a copy of the registry and not the registry itself</h2>
 *
 * The real registry is {@code archived/archive.json} in the repository: 32
 * projects, nineteen fields each, several hundred lines. A mod jar does not need
 * that, and shipping it would create a second copy that goes stale silently.
 *
 * <p>What the mod needs is one question answered - "is this pack a retired one?" -
 * so the resource contains only the three fields that answer it: id, the content
 * hash it was retired at (when known), and a one-line reason. It is generated from
 * the registry, not maintained by hand, and
 * {@code tools/test_scan_parity.py}'s sibling check asserts that every id here
 * exists in the registry.
 *
 * <h2>Matching</h2>
 *
 * Two ways, because a pack can be recognised by either:
 *
 * <ul>
 *   <li>the content hash matches an entry, which identifies the exact bytes that
 *       were retired;</li>
 *   <li>the pack's own {@code pack.mcmeta} declares
 *       {@code "vortaforge": {"status": "archived"}}, which is what a pack author
 *       writes when they retire their own pack.</li>
 * </ul>
 *
 * <p>A pack id match alone is deliberately not enough. Ids are cheap to copy, and
 * matching on one would let any pack claim to be the retired thing.
 */
public final class ArchiveRegistry {
    private static final String RESOURCE = "/assets/macroengine/archive-index.json";
    private static final Type TYPE = new TypeToken<Shape>() { }.getType();

    private static volatile ArchiveRegistry instance;

    private final Map<String, Entry> byHash;
    private final Map<String, Entry> byId;

    private ArchiveRegistry(Map<String, Entry> byHash, Map<String, Entry> byId) {
        this.byHash = byHash;
        this.byId = byId;
    }

    /** One retired project, reduced to what a warning needs. */
    public record Entry(String id, String hash, String reason) {
    }

    private static final class Shape {
        int schemaVersion;
        String generatedFrom;
        List<Entry> projects = List.of();
    }

    /**
     * Load once. A missing or broken resource yields an empty registry, which
     * makes every pack "not archived" - the warning then falls back to its general
     * text rather than claiming something it cannot check.
     */
    public static ArchiveRegistry get() {
        ArchiveRegistry local = instance;
        if (local != null) {
            return local;
        }
        synchronized (ArchiveRegistry.class) {
            if (instance == null) {
                instance = loadResource();
            }
            return instance;
        }
    }

    private static ArchiveRegistry loadResource() {
        Map<String, Entry> byHash = new HashMap<>();
        Map<String, Entry> byId = new HashMap<>();
        try (InputStream in = ArchiveRegistry.class.getResourceAsStream(RESOURCE)) {
            if (in == null) {
                return new ArchiveRegistry(byHash, byId);
            }
            try (Reader reader = new InputStreamReader(in, StandardCharsets.UTF_8)) {
                Shape shape = new Gson().fromJson(reader, TYPE);
                if (shape == null || shape.projects == null) {
                    return new ArchiveRegistry(byHash, byId);
                }
                for (Entry entry : shape.projects) {
                    if (entry == null || entry.id() == null || entry.id().isBlank()) {
                        continue;
                    }
                    byId.put(normalise(entry.id()), entry);
                    if (entry.hash() != null && !entry.hash().isBlank()) {
                        byHash.put(entry.hash().toLowerCase(Locale.ROOT), entry);
                    }
                }
            }
        // JsonSyntaxException extends RuntimeException, so it must not appear
        // alongside it in a multi-catch: the alternatives may not be related by
        // subclassing, and IOException | RuntimeException already covers both.
        } catch (IOException | RuntimeException e) {
            // An unreadable registry must not take world load down, and must not
            // pretend packs are archived either.
            return new ArchiveRegistry(new HashMap<>(), new HashMap<>());
        }
        return new ArchiveRegistry(byHash, byId);
    }

    /** Match by content hash - the only match that identifies the exact bytes. */
    public Optional<Entry> byContentHash(String hash) {
        if (hash == null || hash.isBlank()) {
            return Optional.empty();
        }
        return Optional.ofNullable(byHash.get(hash.toLowerCase(Locale.ROOT)));
    }

    /** Look up an entry by id, for the "this is the retired macroEngine pack" case. */
    public Optional<Entry> byPackId(String id) {
        if (id == null || id.isBlank()) {
            return Optional.empty();
        }
        return Optional.ofNullable(byId.get(normalise(id)));
    }

    /**
     * True when the pack is archived, by hash or by its own declared status.
     *
     * <p>A declared {@code vortaforge.status} of {@code archived} is honoured on
     * any pack id, because the declaration is the pack author's own statement and
     * the consequence is only a stronger warning.
     */
    public boolean isArchived(String packId, String contentHash, boolean declaresArchived) {
        return declaresArchived || byContentHash(contentHash).isPresent();
    }

    public int size() {
        return byId.size();
    }

    private static String normalise(String s) {
        return s.trim().toLowerCase(Locale.ROOT);
    }
}
