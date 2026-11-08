package net.vortaforge.macroengine.command;

import net.vortaforge.macroengine.ack.ArchiveRegistry;
import net.vortaforge.macroengine.ack.DeclaredStatus;

import java.io.IOException;
import java.nio.charset.StandardCharsets;
import java.nio.file.Files;
import java.nio.file.Path;
import java.util.zip.ZipEntry;
import java.util.zip.ZipFile;

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
    private ArchiveLookup() {
    }

    static boolean isArchived(String packId, String hash, Path packFile) {
        ArchiveRegistry registry = ArchiveRegistry.get();
        if (registry.byContentHash(hash).isPresent()) {
            return true;
        }
        return DeclaredStatus.declaresArchived(readPackMeta(packFile));
    }

    /** Read {@code pack.mcmeta} from a pack directory or a pack zip. Null on any failure. */
    static String readPackMeta(Path packFile) {
        if (packFile == null) {
            return null;
        }
        try {
            if (Files.isDirectory(packFile)) {
                Path meta = packFile.resolve("pack.mcmeta");
                return Files.isRegularFile(meta) ? Files.readString(meta, StandardCharsets.UTF_8) : null;
            }
            if (Files.isRegularFile(packFile)) {
                try (ZipFile zip = new ZipFile(packFile.toFile())) {
                    ZipEntry entry = zip.getEntry("pack.mcmeta");
                    if (entry == null) {
                        return null;
                    }
                    try (var in = zip.getInputStream(entry)) {
                        return new String(in.readAllBytes(), StandardCharsets.UTF_8);
                    }
                }
            }
        } catch (IOException | RuntimeException e) {
            // An unreadable pack.mcmeta means "no declaration", which is the
            // conservative answer: the general warning assumes less.
            return null;
        }
        return null;
    }
}
