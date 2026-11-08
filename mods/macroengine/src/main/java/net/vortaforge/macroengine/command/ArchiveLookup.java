package net.vortaforge.macroengine.command;

import net.minecraft.resources.Identifier;
import net.minecraft.server.packs.PackResources;
import net.minecraft.server.packs.PackType;
import net.minecraft.server.packs.repository.Pack;
import net.vortaforge.macroengine.ack.ArchiveRegistry;
import net.vortaforge.macroengine.ack.DeclaredStatus;

import java.io.IOException;
import java.io.InputStream;
import java.nio.charset.StandardCharsets;
import java.util.concurrent.atomic.AtomicReference;

/**
 * Answers "is this pack a retired one?" for the command layer.
 *
 * <p>Two signals, and either is enough to make the warning harsher:
 *
 * <ul>
 *   <li>the content hash is in {@link ArchiveRegistry}, which identifies the exact
 *       bytes that were retired;</li>
 *   <li>the pack's own {@code pack.mcmeta} declares
 *       {@code "vortaforge": {"status": "archived"}}.</li>
 * </ul>
 *
 * <p>Reading {@code pack.mcmeta} here is a small duplicated read - the scanner
 * already parses the same file through the resource manager - because this runs on
 * a command, not on world load, and reaching into the scanner's report for one
 * boolean would couple two things that do not need to know each other.
 */
final class ArchiveLookup {
    /**
     * The resource id of a pack's own metadata file.
     *
     * <p>The name is {@code pack.mcmeta} at the pack root, which the game models as
     * a resource in the {@code minecraft} namespace. If this turns out to be the
     * wrong id for 26.3, the only consequence is that a pack declaring its own
     * archived status is not recognised as archived - the hash-based match and the
     * general warning are unaffected, and nothing is ever refused on this basis.
     */
    private static final Identifier PACK_META_ID =
            Identifier.fromNamespaceAndPath("minecraft", "pack.mcmeta");

    private ArchiveLookup() {
    }

    static boolean isArchived(String packId, String hash, Pack pack) {
        ArchiveRegistry registry = ArchiveRegistry.get();
        if (registry.byContentHash(hash).isPresent()) {
            return true;
        }
        return DeclaredStatus.declaresArchived(readPackMeta(pack));
    }

    /**
     * Read {@code pack.mcmeta} through the pack's own resource access.
     *
     * <p>Not from a path: {@code Pack} has none. {@code PACK_META} is the id the
     * game uses for the file itself, so this asks the same question the game asks
     * rather than reconstructing a filename.
     */
    static String readPackMeta(Pack pack) {
        if (pack == null) {
            return null;
        }
        AtomicReference<String> found = new AtomicReference<>(null);
        try (var stream = pack.open()) {
            for (PackResources source : stream.toList()) {
                var supplier = source.getResource(PackType.SERVER_DATA, PACK_META_ID);
                if (supplier == null) {
                    continue;
                }
                try (InputStream in = supplier.get()) {
                    found.set(new String(in.readAllBytes(), StandardCharsets.UTF_8));
                    break;
                }
            }
        } catch (IOException | RuntimeException e) {
            // An unreadable pack.mcmeta means "no declaration", which is the
            // conservative answer: the general warning assumes less.
            return null;
        }
        return found.get();
    }
}
