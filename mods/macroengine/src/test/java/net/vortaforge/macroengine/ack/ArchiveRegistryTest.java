package net.vortaforge.macroengine.ack;

import org.junit.jupiter.api.Test;

import static org.junit.jupiter.api.Assertions.assertFalse;
import static org.junit.jupiter.api.Assertions.assertTrue;

/**
 * Archive matching, against the real generated resource on the classpath.
 *
 * <p>This is not a mock: it loads
 * {@code assets/macroengine/archive-index.json}, which means a stale or empty
 * registry fails here as well as in {@code build_archive_index.py --check}.
 */
class ArchiveRegistryTest {

    @Test
    void registryLoadsAndMatchesTheMacroEnginePackByHash() {
        ArchiveRegistry registry = ArchiveRegistry.get();
        assertTrue(registry.size() >= 10, "expected the archived packs, got " + registry.size());

        var entry = registry.byPackId("macroengine-datapack");
        assertTrue(entry.isPresent(), "the macroEngine pack must be in the registry");
        assertTrue(entry.get().hash() != null && !entry.get().hash().isBlank(),
                "an entry without a hash cannot identify anything");
    }

    @Test
    void everyEntryHasAHashAndAReason() {
        ArchiveRegistry registry = ArchiveRegistry.get();
        for (String id : new String[]{"macroengine-datapack", "dailybonus", "quickshare"}) {
            var entry = registry.byPackId(id);
            assertTrue(entry.isPresent(), id + " is missing from the registry");
            assertTrue(entry.get().hash().length() == 64,
                    id + " hash is not a SHA-256: " + entry.get().hash());
            assertFalse(entry.get().reason().isBlank(), id + " has no reason");
        }
    }

    @Test
    void anUnknownHashIsNotArchived() {
        assertTrue(ArchiveRegistry.get().byContentHash("0".repeat(64)).isEmpty());
    }

    @Test
    void aDeclaredStatusIsHonouredOnAnyPackId() {
        ArchiveRegistry registry = ArchiveRegistry.get();
        // Even an id the registry has never heard of is archived if the pack says
        // so itself: the declaration is the author's, and it only makes the
        // warning stronger.
        assertTrue(registry.isArchived("some-other-pack", "0".repeat(64), true));
        assertFalse(registry.isArchived("some-other-pack", "0".repeat(64), false));
    }

    @Test
    void blankInputsAreNotArchived() {
        ArchiveRegistry registry = ArchiveRegistry.get();
        assertTrue(registry.byContentHash(null).isEmpty());
        assertTrue(registry.byContentHash("").isEmpty());
        assertTrue(registry.byPackId(null).isEmpty());
        assertTrue(registry.byPackId("  ").isEmpty());
    }
}
