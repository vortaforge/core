package net.vortaforge.macroengine.ack;

import org.junit.jupiter.api.Test;
import org.junit.jupiter.api.io.TempDir;

import java.io.IOException;
import java.nio.charset.StandardCharsets;
import java.nio.file.Files;
import java.nio.file.Path;

import static org.junit.jupiter.api.Assertions.assertEquals;
import static org.junit.jupiter.api.Assertions.assertFalse;
import static org.junit.jupiter.api.Assertions.assertTrue;

/**
 * The acknowledgement record.
 *
 * <p>The behaviour under test is mostly about what happens when things are wrong:
 * a missing file, a truncated file, a record from another schema, a hash that no
 * longer matches. Every one of those must read as "not acknowledged", because the
 * alternative is trusting a pack nobody approved.
 */
class AcknowledgementStoreTest {

    @TempDir
    Path temp;

    private Path record() {
        return temp.resolve("macroengine").resolve("acknowledged.json");
    }

    @Test
    void missingFileMeansNothingIsAcknowledged() {
        AcknowledgementStore store = AcknowledgementStore.load(record());
        assertFalse(store.isAcknowledged("pack.zip", "abc"));
        assertEquals(0, store.size());
    }

    @Test
    void acknowledgingThenReadingBackMatchesOnlyTheSameHash() throws IOException {
        AcknowledgementStore store = AcknowledgementStore.load(record());
        store.acknowledge("pack.zip", "hash-one", "tickwarden", "2026-11-08T10:00:00Z");

        AcknowledgementStore reloaded = AcknowledgementStore.load(record());
        assertTrue(reloaded.isAcknowledged("pack.zip", "hash-one"));
        assertFalse(reloaded.isAcknowledged("pack.zip", "hash-two"),
                "a different hash is a different pack version");
    }

    @Test
    void malformedJsonReadsAsUnacknowledged() throws IOException {
        Files.createDirectories(record().getParent());
        Files.writeString(record(), "{ this is not json", StandardCharsets.UTF_8);

        AcknowledgementStore store = AcknowledgementStore.load(record());
        assertFalse(store.isAcknowledged("pack.zip", "hash-one"));
        assertEquals(0, store.size(), "a corrupt record must not be half-trusted");
    }

    @Test
    void truncatedFileReadsAsUnacknowledged() throws IOException {
        Files.createDirectories(record().getParent());
        Files.writeString(record(), "{\"schemaVersion\":1,\"packs\":{\"pack.zip\":{\"hash\":",
                StandardCharsets.UTF_8);

        assertFalse(AcknowledgementStore.load(record()).isAcknowledged("pack.zip", "hash-one"));
    }

    @Test
    void unknownSchemaReadsAsUnacknowledged() throws IOException {
        Files.createDirectories(record().getParent());
        Files.writeString(record(),
                "{\"schemaVersion\":99,\"packs\":{\"pack.zip\":{\"hash\":\"hash-one\"}}}",
                StandardCharsets.UTF_8);

        AcknowledgementStore store = AcknowledgementStore.load(record());
        assertFalse(store.isAcknowledged("pack.zip", "hash-one"),
                "a newer schema is not something to guess at");
    }

    @Test
    void entryWithoutAHashIsDropped() throws IOException {
        Files.createDirectories(record().getParent());
        Files.writeString(record(),
                "{\"schemaVersion\":1,\"packs\":{\"pack.zip\":{\"acknowledgedBy\":\"x\"}}}",
                StandardCharsets.UTF_8);

        AcknowledgementStore store = AcknowledgementStore.load(record());
        assertEquals(0, store.size());
        assertFalse(store.isAcknowledged("pack.zip", ""));
    }

    @Test
    void packIdsAreCaseAndSeparatorInsensitive() throws IOException {
        AcknowledgementStore store = AcknowledgementStore.load(record());
        store.acknowledge("File\\MyPack.zip", "h", "op", "now");

        assertTrue(AcknowledgementStore.load(record()).isAcknowledged("file/mypack.zip", "h"),
                "the same pack named two ways must not ask twice");
    }

    @Test
    void rewritingWithANewHashReplacesTheOldEntry() throws IOException {
        AcknowledgementStore store = AcknowledgementStore.load(record());
        store.acknowledge("pack.zip", "old-hash", "op", "then");
        store.acknowledge("pack.zip", "new-hash", "op", "now");

        AcknowledgementStore reloaded = AcknowledgementStore.load(record());
        assertEquals(1, reloaded.size(), "one entry per pack id, replaced in place");
        assertFalse(reloaded.isAcknowledged("pack.zip", "old-hash"));
        assertTrue(reloaded.isAcknowledged("pack.zip", "new-hash"));
    }

    @Test
    void writeIsAtomicEnoughToNeverLeaveATruncatedRecord() throws IOException {
        AcknowledgementStore store = AcknowledgementStore.load(record());
        store.acknowledge("a.zip", "hash-a", "op", "now");
        store.acknowledge("b.zip", "hash-b", "op", "now");

        // The temp file must not survive a successful save.
        assertFalse(Files.exists(record().resolveSibling("acknowledged.json.tmp")));
        assertTrue(Files.size(record()) > 0);
    }

    @Test
    void clearRemovesEverything() throws IOException {
        AcknowledgementStore store = AcknowledgementStore.load(record());
        store.acknowledge("a.zip", "hash-a", "op", "now");
        store.clear();

        assertEquals(0, AcknowledgementStore.load(record()).size());
    }

    @Test
    void savedFileIsReadableJson() throws IOException {
        AcknowledgementStore store = AcknowledgementStore.load(record());
        store.acknowledge("a.zip", "hash-a", "op", "2026-11-08T10:00:00Z");

        String text = Files.readString(record(), StandardCharsets.UTF_8);
        assertTrue(text.contains("\"schemaVersion\""));
        assertTrue(text.contains("\"hash-a\""));
        // No trailing garbage from a partial write.
        assertTrue(text.trim().endsWith("}"));
    }
}
