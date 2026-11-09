package com.vortaforge.homemanager;

// AI-assisted: written with Claude (Anthropic). See CREDITS.md at the repo root.

import static com.vortaforge.homemanager.HomeBook.SetResult.*;
import static org.junit.jupiter.api.Assertions.*;

import java.util.List;
import java.util.Map;
import org.junit.jupiter.api.Test;

class HomeBookTest {

    private static Home at(double x) {
        return new Home("minecraft:overworld", x, 64, 0, 0f, 0f);
    }

    @Test void setThenGet() {
        HomeBook b = new HomeBook(3);
        assertEquals(CREATED, b.set("u", "base", at(1)));
        assertEquals(at(1), b.get("u", "base"));
        assertNull(b.get("u", "nope"));
        assertNull(b.get("other", "base"));
    }

    @Test void namesAreCaseInsensitiveAndTrimmed() {
        HomeBook b = new HomeBook(3);
        b.set("u", "  Base ", at(1));
        assertEquals(at(1), b.get("u", "BASE"));
        assertEquals(List.of("base"), b.names("u"));
    }

    @Test void invalidNamesAreRejected() {
        HomeBook b = new HomeBook(3);
        for (String bad : new String[] {"", " ", "a b", "ünï", "x".repeat(17), "a/b", "a.b", "../x", null}) {
            assertEquals(BAD_NAME, b.set("u", bad, at(1)), "name: " + bad);
        }
        assertTrue(b.names("u").isEmpty());
    }

    @Test void acceptsEdgeValidNames() {
        HomeBook b = new HomeBook(5);
        assertEquals(CREATED, b.set("u", "a", at(1)));
        assertEquals(CREATED, b.set("u", "x".repeat(16), at(1)));
        assertEquals(CREATED, b.set("u", "my_home-2", at(1)));
    }

    @Test void replacingKeepsTheSlotAndMovesTheHome() {
        HomeBook b = new HomeBook(1);
        assertEquals(CREATED, b.set("u", "a", at(1)));
        assertEquals(REPLACED, b.set("u", "A", at(2)));
        assertEquals(at(2), b.get("u", "a"));
    }

    @Test void limitBlocksNewHomesOnly() {
        HomeBook b = new HomeBook(2);
        b.set("u", "a", at(1));
        b.set("u", "b", at(2));
        assertEquals(LIMIT, b.set("u", "c", at(3)));
        assertNull(b.get("u", "c"));
        assertEquals(REPLACED, b.set("u", "a", at(9)));      // reusing a name is still allowed at the limit
        assertEquals(CREATED, b.set("other", "a", at(1)));   // limit is per owner
    }

    @Test void deleteFreesASlot() {
        HomeBook b = new HomeBook(1);
        b.set("u", "a", at(1));
        assertEquals(LIMIT, b.set("u", "b", at(2)));
        assertTrue(b.delete("u", "A"));
        assertFalse(b.delete("u", "a"));
        assertEquals(CREATED, b.set("u", "b", at(2)));
    }

    @Test void namesAreSorted() {
        HomeBook b = new HomeBook(5);
        b.set("u", "zeta", at(1));
        b.set("u", "alpha", at(1));
        b.set("u", "mid", at(1));
        assertEquals(List.of("alpha", "mid", "zeta"), b.names("u"));
        assertTrue(b.names("nobody").isEmpty());
    }

    @Test void snapshotIsADeepCopy() {
        HomeBook b = new HomeBook(3);
        b.set("u", "a", at(1));
        Map<String, Map<String, Home>> snap = b.snapshot();
        b.set("u", "b", at(2));
        assertEquals(1, snap.get("u").size());
        assertThrows(UnsupportedOperationException.class, () -> snap.get("u").put("x", at(3)));
    }

    @Test void restoreRoundTripsASnapshot() {
        HomeBook b = new HomeBook(3);
        b.set("u", "a", at(1));
        b.set("v", "b", at(2));
        HomeBook copy = HomeBook.restore(3, b.snapshot());
        assertEquals(at(1), copy.get("u", "a"));
        assertEquals(at(2), copy.get("v", "b"));
    }

    @Test void restoreSkipsBadEntriesButKeepsGoodOnes() {
        Map<String, Map<String, Home>> stored = new java.util.LinkedHashMap<>();
        Map<String, Home> homes = new java.util.LinkedHashMap<>();
        homes.put("good", at(1));
        homes.put("Bad Name", at(2));
        homes.put("nullhome", null);
        homes.put("nodim", new Home(null, 0, 0, 0, 0f, 0f));
        stored.put("u", homes);
        stored.put("empty", new java.util.LinkedHashMap<>());
        stored.put("nullowner-homes", null);
        HomeBook b = HomeBook.restore(3, stored);
        assertEquals(List.of("good"), b.names("u"));
        assertTrue(b.names("empty").isEmpty());
    }

    @Test void loweredLimitNeverDeletesExistingHomes() {
        HomeBook big = new HomeBook(5);
        for (String n : new String[] {"a", "b", "c", "d"}) big.set("u", n, at(1));
        HomeBook small = HomeBook.restore(2, big.snapshot());
        assertEquals(4, small.names("u").size());
        assertEquals(LIMIT, small.set("u", "e", at(1)));
        assertEquals(REPLACED, small.set("u", "a", at(2)));
    }

    @Test void restoreNullIsEmpty() {
        assertTrue(HomeBook.restore(3, null).names("u").isEmpty());
    }

    @Test void rejectsNonPositiveLimit() {
        assertThrows(IllegalArgumentException.class, () -> new HomeBook(0));
    }
}
