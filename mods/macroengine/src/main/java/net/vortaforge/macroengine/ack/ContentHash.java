package net.vortaforge.macroengine.ack;

import java.io.IOException;
import java.io.InputStream;
import java.nio.charset.StandardCharsets;
import java.nio.file.Files;
import java.nio.file.Path;
import java.security.MessageDigest;
import java.security.NoSuchAlgorithmException;
import java.util.ArrayList;
import java.util.Enumeration;
import java.util.HexFormat;
import java.util.List;
import java.util.stream.Stream;
import java.util.zip.ZipEntry;
import java.util.zip.ZipFile;

/**
 * A content hash for a data pack, so an acknowledgement can be bound to a version.
 *
 * <h2>What is hashed, and what deliberately is not</h2>
 *
 * A pack can arrive as a directory or as a zip. Both are reduced to the same
 * shape before hashing: the sorted list of relative paths, paired with the bytes
 * of each file, folded into one SHA-256.
 *
 * <p>Two properties matter and they pull in opposite directions.
 *
 * <ul>
 *   <li><b>Stable across machines.</b> Absolute paths, file modification times and
 *       directory iteration order must not reach the digest, or the same pack
 *       produces different hashes on two machines and every acknowledgement is
 *       immediately stale.</li>
 *   <li><b>Sensitive to content.</b> Renaming a file, editing one byte, or adding
 *       a file must all change the digest, because all three change what the game
 *       will execute.</li>
 * </ul>
 *
 * <p>The separator bytes below are what keep the two from bleeding into each
 * other: without a delimiter between a path and the next file's content, moving a
 * byte from one file to the next could leave the concatenation unchanged. The
 * lengths are hashed in too, for the same reason.
 *
 * <h2>Why this class has no Minecraft types in it</h2>
 *
 * So it can be tested without a game: {@code ContentHashTest} runs it against
 * temporary directories and zips in plain JUnit.
 */
public final class ContentHash {
    private ContentHash() {
    }

    /**
     * Hash a pack directory.
     *
     * @throws IOException if the tree cannot be walked or a file cannot be read.
     *                     Callers must treat this as "unacknowledged", never as
     *                     "unchanged" - see {@link AcknowledgementStore}.
     */
    public static String ofDirectory(Path root) throws IOException {
        List<Path> files = new ArrayList<>();
        try (Stream<Path> walk = Files.walk(root)) {
            walk.filter(Files::isRegularFile).forEach(files::add);
        }
        files.sort((a, b) -> relative(root, a).compareTo(relative(root, b)));

        MessageDigest digest = sha256();
        for (Path file : files) {
            String rel = relative(root, file);
            feed(digest, rel, Files.readAllBytes(file));
        }
        return HexFormat.of().formatHex(digest.digest());
    }

    /**
     * Hash a pack zip.
     *
     * <p>Entries are read in sorted order rather than archive order, because the
     * same files zipped twice need not produce the same entry order and a pack
     * re-zipped by a launcher should not look like a new pack.
     */
    public static String ofZip(Path zip) throws IOException {
        List<String> names = new ArrayList<>();
        try (ZipFile file = new ZipFile(zip.toFile())) {
            Enumeration<? extends ZipEntry> entries = file.entries();
            while (entries.hasMoreElements()) {
                ZipEntry entry = entries.nextElement();
                if (!entry.isDirectory()) {
                    names.add(entry.getName());
                }
            }
            names.sort(String::compareTo);

            MessageDigest digest = sha256();
            for (String name : names) {
                ZipEntry entry = file.getEntry(name);
                if (entry == null) {
                    continue;
                }
                try (InputStream in = file.getInputStream(entry)) {
                    feed(digest, name, in.readAllBytes());
                }
            }
            return HexFormat.of().formatHex(digest.digest());
        }
    }

    /** Dispatch on what the path actually is. */
    public static String of(Path path) throws IOException {
        if (Files.isDirectory(path)) {
            return ofDirectory(path);
        }
        if (Files.isRegularFile(path)) {
            return ofZip(path);
        }
        throw new IOException("not a directory or a file: " + path);
    }

    /**
     * Fold one path and its content into the digest.
     *
     * <p>A length prefix on both the name and the content is what makes the
     * framing unambiguous. Two short files cannot be made to hash the same as one
     * long one by choosing names carefully.
     */
    private static void feed(MessageDigest digest, String relativePath, byte[] content) {
        byte[] name = relativePath.replace('\\', '/').getBytes(StandardCharsets.UTF_8);
        digest.update(intBytes(name.length));
        digest.update(name);
        digest.update(intBytes(content.length));
        digest.update(content);
    }

    private static byte[] intBytes(int value) {
        return new byte[]{
                (byte) (value >>> 24),
                (byte) (value >>> 16),
                (byte) (value >>> 8),
                (byte) value
        };
    }

    private static String relative(Path root, Path file) {
        return root.relativize(file).toString().replace('\\', '/');
    }

    private static MessageDigest sha256() {
        try {
            return MessageDigest.getInstance("SHA-256");
        } catch (NoSuchAlgorithmException e) {
            // Every conforming JRE ships SHA-256. Reaching this means the runtime
            // is not one this mod can trust to validate anything.
            throw new IllegalStateException("SHA-256 is unavailable", e);
        }
    }
}
