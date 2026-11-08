package net.vortaforge.macroengine.command;

import net.minecraft.resources.Identifier;
import net.minecraft.server.packs.PackResources;
import net.minecraft.server.packs.PackType;
import net.minecraft.server.packs.repository.Pack;
import net.minecraft.server.packs.resources.IoSupplier;
import net.vortaforge.macroengine.ack.ContentHash;

import java.io.IOException;
import java.io.InputStream;
import java.util.HashMap;
import java.util.Map;

/**
 * Content hash for a pack the game has already loaded.
 *
 * <h2>Why this is not a {@code Path}</h2>
 *
 * The first version of this class asked {@code Pack} for its file and hashed that,
 * which does not compile: verified against the 26.3 server jar, {@code Pack}
 * exposes {@code location()}, {@code getId()}, {@code open()}, and a
 * {@code ResourcesSupplier} - and no path at all. {@code PackLocationInfo} carries
 * only {@code id()}, {@code title()}, {@code source()} and {@code knownPackInfo()}.
 *
 * <p>Guessing a path from the id and the usual folder layout would have compiled
 * and hashed the wrong bytes for every pack not in the default folder, which is
 * worse than the compile error: an acknowledgement that never matches what the
 * server computed silently re-prompts forever, or worse, matches a different
 * pack's contents.
 *
 * <h2>What is hashed instead</h2>
 *
 * The resources the game will actually load, read through
 * {@link PackResources#listResources}, which is defined for every pack type -
 * folder, zip, or built-in - with the same {@code (namespace, path)} names. A
 * folder pack and a zip pack holding the same files therefore produce the same
 * digest, which is what makes an acknowledgement written on one machine
 * comparable with one written on another.
 *
 * <p>The {@code assets} and {@code data} roots are hashed together, as
 * {@code assets/...} and {@code data/...}, so a pack cannot change one without
 * changing the hash.
 */
final class PackHasher {
    /** The pack types a datapack can carry. Order matters only for readability. */
    private static final PackType[] TYPES = {PackType.SERVER_DATA, PackType.CLIENT_RESOURCES};

    private PackHasher() {
    }

    /**
     * The content hash for one pack, or null when it cannot be read.
     *
     * <p>Null is the safe answer: {@code PackGate} treats an unhashable pack as
     * unacknowledged rather than as approved.
     */
    static String hashOf(Pack pack) {
        Map<String, byte[]> entries = new HashMap<>();
        try (var stream = pack.open()) {
            // `open()` returns a Stream that must be closed; `toList()` gives a
            // List that cannot be. Closing the stream is what releases the
            // underlying zip handles, so it is the stream that goes in the
            // try-with-resources.
            for (PackResources source : stream.toList()) {
                collect(source, entries);
            }
        } catch (RuntimeException e) {
            // A pack that cannot be read is not a pack that can be approved.
            return null;
        }
        if (entries.isEmpty()) {
            // An empty read is indistinguishable from a pack with no content, and
            // returning the empty-tree digest would let it match a real empty pack.
            return null;
        }
        return ContentHash.ofResources(entries);
    }

    private static void collect(PackResources source, Map<String, byte[]> into) {
        for (PackType type : TYPES) {
            String root = type.getDirectory();          // "data" or "assets"
            for (String namespace : source.getNamespaces(type)) {
                // `listResources` walks the tree and hands back one (id, opener)
                // per file. The namespace is not always the one that was asked
                // for when a pack uses overlays, so the id is used verbatim.
                source.listResources(type, namespace, "", (id, opener) ->
                        read(root, id, opener, into));
            }
        }
    }

    private static void read(String root, Identifier id, IoSupplier<InputStream> opener,
                             Map<String, byte[]> into) {
        String path = root + "/" + id.getNamespace() + "/" + id.getPath();
        if (into.containsKey(path)) {
            return;
        }
        try (InputStream in = opener.get()) {
            into.put(path, in.readAllBytes());
        } catch (IOException | RuntimeException e) {
            // Leave the file out rather than hashing a partial read. The digest
            // then differs from a complete read of the same pack, which is the
            // correct outcome: we could not verify what it contains.
        }
    }
}
