package net.vortaforge.macroengine.ack;

import net.fabricmc.loader.api.FabricLoader;
import org.slf4j.Logger;
import org.slf4j.LoggerFactory;

import java.io.IOException;
import java.nio.file.Path;
import java.time.Instant;
import java.util.Optional;

/**
 * Decides whether a pack has been acknowledged, and records it when it is.
 *
 * <h2>What this is not</h2>
 *
 * This is not the gate that was removed. That one refused to let the engine start
 * and could not be satisfied by someone who had done nothing wrong. This one asks
 * a question with an answer: has <em>this person</em> seen <em>this version</em> of
 * <em>this pack</em>? Once the answer is yes it never asks again, and there is no
 * state in which an unacknowledged pack is "blocked" beyond the prompt that offers
 * to acknowledge it.
 *
 * <p>Two deliberate limits:
 *
 * <ul>
 *   <li>An unacknowledged pack is a prompt, not a refusal - with one exception, the
 *       dedicated-server {@code /datapack enable} path, where there is no screen to
 *       show and silently proceeding would be the worse of the two failures.</li>
 *   <li>Nothing here acts on a scanner finding. A finding makes the text harsher;
 *       it never makes the decision.</li>
 * </ul>
 */
public final class PackGate {
    private static final Logger LOG = LoggerFactory.getLogger("macroengine-ack");

    private static volatile PackGate instance;

    private final AcknowledgementStore store;

    private PackGate(AcknowledgementStore store) {
        this.store = store;
    }

    /** The process-wide instance, created on first use. */
    public static PackGate get() {
        PackGate local = instance;
        if (local != null) {
            return local;
        }
        synchronized (PackGate.class) {
            if (instance == null) {
                Path configDir = FabricLoader.getInstance().getConfigDir().resolve("macroengine");
                instance = new PackGate(AcknowledgementStore.load(configDir.resolve("acknowledged.json")));
            }
            return instance;
        }
    }

    /** Re-read the record from disk. Used by {@code /macroengine ack reload}. */
    public static synchronized void reload() {
        instance = null;
    }

    /** Where the record lives, for a message that tells an operator where to look. */
    public Path recordPath() {
        return store.path();
    }

    /**
     * The verdict for one pack.
     *
     * @param packId  how the game names the pack
     * @param hash    its content hash, or null when it could not be computed
     * @param archived whether it is a retired pack, for the harsher text
     */
    public record Verdict(boolean acknowledged, String packId, String hash, boolean archived, String reason) {
        /** True when the caller must ask before loading. */
        public boolean needsAsking() {
            return !acknowledged;
        }
    }

    /**
     * Decide whether a pack needs to be acknowledged.
     *
     * <p>A pack whose hash cannot be computed is never acknowledged. That is the
     * fail-closed direction and it is the correct one here: an unreadable pack is
     * exactly the pack whose contents nobody can vouch for.
     */
    public Verdict verdict(String packId, String hash, boolean archived, String reason) {
        if (hash == null || hash.isBlank()) {
            return new Verdict(false, packId, hash, archived,
                    "the pack's contents could not be hashed, so no earlier approval can apply");
        }
        boolean known = store.isAcknowledged(packId, hash);
        return new Verdict(known, packId, hash, archived,
                known ? "acknowledged at this content hash" : "not acknowledged at this content hash");
    }

    /** Record an acknowledgement. Returns false when it could not be saved. */
    public boolean acknowledge(String packId, String hash, String by) {
        if (hash == null || hash.isBlank()) {
            LOG.warn("macroEngine: refusing to acknowledge {} - no content hash", packId);
            return false;
        }
        try {
            store.acknowledge(packId, hash, by, Instant.now().toString());
            LOG.info("macroEngine: acknowledged {} at {} by {}", packId,
                    hash.length() > 12 ? hash.substring(0, 12) : hash, by);
            return true;
        } catch (IOException e) {
            // Not fatal: the pack stays unacknowledged, which is the safe state,
            // and the operator is told why the write failed.
            LOG.error("macroEngine: could not write {} - {}", recordPath(), e.toString());
            return false;
        }
    }

    /** The recorded entry for a pack, for "you approved this on ..." text. */
    public Optional<AcknowledgementStore.Entry> entryFor(String packId) {
        return store.entryFor(packId);
    }

    /**
     * Content hash for a pack directory on disk.
     *
     * <p>Returns null on failure rather than throwing: a hash failure must reach
     * the user as a prompt, not as a crash during world load.
     */
    public static String hashOf(Path path) {
        try {
            return ContentHash.of(path);
        } catch (IOException | RuntimeException e) {
            LOG.warn("macroEngine: could not hash {} - {}", path, e.toString());
            return null;
        }
    }
}
