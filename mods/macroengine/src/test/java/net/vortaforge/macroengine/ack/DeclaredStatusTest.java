package net.vortaforge.macroengine.ack;

import org.junit.jupiter.api.Test;

import static org.junit.jupiter.api.Assertions.assertEquals;
import static org.junit.jupiter.api.Assertions.assertFalse;
import static org.junit.jupiter.api.Assertions.assertNull;
import static org.junit.jupiter.api.Assertions.assertTrue;

/**
 * Reading {@code "vortaforge": {"status": "archived"}} out of a pack.mcmeta.
 *
 * <p>Every input here is a file from a pack the scanner is already suspicious of,
 * so the interesting cases are the malformed ones.
 */
class DeclaredStatusTest {

    @Test
    void readsTheDeclaredStatus() {
        String meta = """
                {"pack":{"description":"x"},"vortaforge":{"status":"archived"}}
                """;
        assertTrue(DeclaredStatus.declaresArchived(meta));
        assertEquals("archived", DeclaredStatus.status(meta));
    }

    @Test
    void statusIsCaseInsensitive() {
        assertTrue(DeclaredStatus.declaresArchived(
                "{\"vortaforge\":{\"status\":\"ArChIvEd\"}}"));
    }

    @Test
    void aDifferentStatusIsNotArchived() {
        assertFalse(DeclaredStatus.declaresArchived(
                "{\"vortaforge\":{\"status\":\"active\"}}"));
        assertEquals("active", DeclaredStatus.status("{\"vortaforge\":{\"status\":\"active\"}}"));
    }

    @Test
    void absentBlockMeansNoDeclaration() {
        assertNull(DeclaredStatus.status("{\"pack\":{\"description\":\"x\"}}"));
        assertFalse(DeclaredStatus.declaresArchived("{\"pack\":{}}"));
    }

    @Test
    void malformedJsonMeansNoDeclaration() {
        assertNull(DeclaredStatus.status("{not json"));
        assertNull(DeclaredStatus.status("[]"));
        assertNull(DeclaredStatus.status(""));
        assertNull(DeclaredStatus.status(null));
    }

    @Test
    void statusOfTheWrongTypeMeansNoDeclaration() {
        assertNull(DeclaredStatus.status("{\"vortaforge\":{\"status\":1}}"));
        assertNull(DeclaredStatus.status("{\"vortaforge\":{\"status\":null}}"));
        assertNull(DeclaredStatus.status("{\"vortaforge\":\"archived\"}"),
                "the block must be an object, not a bare string");
    }

    @Test
    void extraFieldsAroundItAreIgnored() {
        String meta = """
                {
                  "pack": {"description": "x", "min_format": [121, 0], "max_format": [121, 0]},
                  "vortaforge": {"status": "archived", "note": "retired 2026-11-05"}
                }
                """;
        assertTrue(DeclaredStatus.declaresArchived(meta));
    }
}
