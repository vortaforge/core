package com.vortaforge.deathpoint;

// AI-assisted: written with Claude (Anthropic). See CREDITS.md at the repo root.

import static org.junit.jupiter.api.Assertions.*;

import org.junit.jupiter.api.Test;

class DeathBookTest {

    private static DeathRecord at(int x) {
        return new DeathRecord("minecraft:overworld", x, 64, 0);
    }

    @Test void unknownPlayerHasNoRecord() {
        assertNull(new DeathBook<String>(10).last("nobody"));
    }

    @Test void latestDeathWins() {
        DeathBook<String> b = new DeathBook<>(10);
        b.record("a", at(1));
        b.record("a", at(2));
        assertEquals(at(2), b.last("a"));
        assertEquals(1, b.size());
    }

    @Test void leastRecentlyUsedPlayersAreForgottenFirst() {
        DeathBook<String> b = new DeathBook<>(2);
        b.record("a", at(1));
        b.record("b", at(2));
        b.last("a");                       // touch a, so b is now the eldest
        b.record("c", at(3));
        assertEquals(at(1), b.last("a"));
        assertNull(b.last("b"));
        assertEquals(at(3), b.last("c"));
    }

    @Test void rejectsNonPositiveCapacity() {
        assertThrows(IllegalArgumentException.class, () -> new DeathBook<String>(0));
    }
}
