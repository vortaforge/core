package net.vortaforge.macroengine.ack;

import org.junit.jupiter.api.Test;
import org.junit.jupiter.api.io.TempDir;

import java.io.IOException;
import java.io.OutputStream;
import java.nio.charset.StandardCharsets;
import java.nio.file.Files;
import java.nio.file.Path;
import java.util.zip.ZipEntry;
import java.util.zip.ZipOutputStream;

import static org.junit.jupiter.api.Assertions.assertEquals;
import static org.junit.jupiter.api.Assertions.assertNotEquals;
import static org.junit.jupiter.api.Assertions.assertThrows;
import static org.junit.jupiter.api.Assertions.assertTrue;

/**
 * The hash is the key an acknowledgement is bound to, so what it is sensitive to
 * is the whole design.
 *
 * <p>These tests are plain JUnit with no game: {@link ContentHash} takes a
 * {@link Path} and nothing else.
 */
class ContentHashTest {

    @TempDir
    Path temp;

    private Path write(Path root, String name, String content) throws IOException {
        Path file = root.resolve(name);
        Files.createDirectories(file.getParent());
        Files.writeString(file, content, StandardCharsets.UTF_8);
        return file;
    }

    @Test
    void sameTreeHashesTheSameRegardlessOfCreationOrder() throws IOException {
        Path a = Files.createDirectories(temp.resolve("a"));
        write(a, "pack.mcmeta", "{}");
        write(a, "data/x/function/y.mcfunction", "say hi");

        Path b = Files.createDirectories(temp.resolve("b"));
        // Written in the opposite order on purpose.
        write(b, "data/x/function/y.mcfunction", "say hi");
        write(b, "pack.mcmeta", "{}");

        assertEquals(ContentHash.ofDirectory(a), ContentHash.ofDirectory(b));
    }

    @Test
    void oneChangedByteChangesTheHash() throws IOException {
        Path root = Files.createDirectories(temp.resolve("pack"));
        Path file = write(root, "data/x/function/y.mcfunction", "say hi");

        String before = ContentHash.ofDirectory(root);
        Files.writeString(file, "say hj", StandardCharsets.UTF_8);
        String after = ContentHash.ofDirectory(root);

        assertNotEquals(before, after, "a changed file must invalidate the acknowledgement");
    }

    @Test
    void renamingAFileChangesTheHash() throws IOException {
        Path one = Files.createDirectories(temp.resolve("one"));
        write(one, "data/x/function/a.mcfunction", "say hi");

        Path two = Files.createDirectories(temp.resolve("two"));
        write(two, "data/x/function/b.mcfunction", "say hi");

        assertNotEquals(ContentHash.ofDirectory(one), ContentHash.ofDirectory(two),
                "the same bytes under a different name execute differently");
    }

    @Test
    void addingAFileChangesTheHash() throws IOException {
        Path root = Files.createDirectories(temp.resolve("pack"));
        write(root, "a.mcfunction", "say hi");
        String before = ContentHash.ofDirectory(root);

        write(root, "b.mcfunction", "");
        assertNotEquals(before, ContentHash.ofDirectory(root));
    }

    /**
     * Without length prefixes, moving a byte from the end of one file to the start
     * of the next would leave the concatenation identical. This is the test that
     * pins the framing.
     */
    @Test
    void contentCannotBeShiftedBetweenFiles() throws IOException {
        Path one = Files.createDirectories(temp.resolve("one"));
        write(one, "a.txt", "AB");
        write(one, "b.txt", "C");

        Path two = Files.createDirectories(temp.resolve("two"));
        write(two, "a.txt", "A");
        write(two, "b.txt", "BC");

        assertNotEquals(ContentHash.ofDirectory(one), ContentHash.ofDirectory(two));
    }

    @Test
    void zipAndDirectoryAgreeWhenTheZipHoldsTheSameFiles() throws IOException {
        Path dir = Files.createDirectories(temp.resolve("pack"));
        write(dir, "pack.mcmeta", "{}");
        write(dir, "data/x/function/y.mcfunction", "say hi");
        String fromDir = ContentHash.ofDirectory(dir);

        Path zip = temp.resolve("pack.zip");
        try (OutputStream out = Files.newOutputStream(zip);
             ZipOutputStream zos = new ZipOutputStream(out)) {
            // Entries written in reverse order: archive order must not matter.
            for (String name : new String[]{"data/x/function/y.mcfunction", "pack.mcmeta"}) {
                zos.putNextEntry(new ZipEntry(name));
                zos.write(Files.readAllBytes(dir.resolve(name)));
                zos.closeEntry();
            }
        }

        assertEquals(fromDir, ContentHash.ofZip(zip));
    }

    @Test
    void directoryEntriesInsideAZipAreIgnored() throws IOException {
        Path zip = temp.resolve("with-dir-entry.zip");
        try (OutputStream out = Files.newOutputStream(zip);
             ZipOutputStream zos = new ZipOutputStream(out)) {
            zos.putNextEntry(new ZipEntry("data/"));
            zos.closeEntry();
            zos.putNextEntry(new ZipEntry("a.txt"));
            zos.write("x".getBytes(StandardCharsets.UTF_8));
            zos.closeEntry();
        }

        Path withoutDirEntry = temp.resolve("no-dir-entry.zip");
        try (OutputStream out = Files.newOutputStream(withoutDirEntry);
             ZipOutputStream zos = new ZipOutputStream(out)) {
            zos.putNextEntry(new ZipEntry("a.txt"));
            zos.write("x".getBytes(StandardCharsets.UTF_8));
            zos.closeEntry();
        }

        assertEquals(ContentHash.ofZip(zip), ContentHash.ofZip(withoutDirEntry),
                "a directory entry carries no content and must not change the hash");
    }

    @Test
    void hashIsLowercaseHexSha256() throws IOException {
        Path root = Files.createDirectories(temp.resolve("pack"));
        write(root, "a.txt", "x");

        String hash = ContentHash.ofDirectory(root);
        assertEquals(64, hash.length(), "SHA-256 is 32 bytes");
        assertTrue(hash.matches("[0-9a-f]{64}"), "expected lowercase hex, got " + hash);
    }

    @Test
    void aPathThatIsNeitherFileNorDirectoryIsRejected() {
        assertThrows(IOException.class, () -> ContentHash.of(temp.resolve("does-not-exist")));
    }

    @Test
    void emptyDirectoryHashesToTheEmptyDigest() throws IOException {
        Path root = Files.createDirectories(temp.resolve("empty"));
        // Not a useful pack, but must not throw: the caller turns a hash into a
        // key and an exception here would reach world load.
        assertEquals("e3b0c44298fc1c149afbf4c8996fb92427ae41e4649b934ca495991b7852b855",
                ContentHash.ofDirectory(root));
    }
}
