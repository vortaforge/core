package com.vortaforge.lagreport;

// AI-assisted: written with Claude (Anthropic). See CREDITS.md at the repo root.

import static org.junit.jupiter.api.Assertions.*;

import java.util.List;
import org.junit.jupiter.api.Test;

class EntityCensusTest {

    private static EntityCensus sample() {
        EntityCensus c = new EntityCensus();
        for (int i = 0; i < 5; i++) c.add("minecraft:item");
        for (int i = 0; i < 3; i++) c.add("minecraft:zombie");
        for (int i = 0; i < 3; i++) c.add("minecraft:cow");
        c.add("minecraft:bat");
        return c;
    }

    @Test void countsTotalAndPerType() {
        EntityCensus c = sample();
        assertEquals(12, c.total());
        assertEquals(new EntityCensus.Count("minecraft:item", 5), c.top(1).get(0));
    }

    @Test void topIsSortedByCountThenTypeId() {
        List<EntityCensus.Count> top = sample().top(3);
        assertEquals("minecraft:item", top.get(0).type());
        assertEquals("minecraft:cow", top.get(1).type());      // tie with zombie (3), cow sorts first
        assertEquals("minecraft:zombie", top.get(2).type());
    }

    @Test void topIsCappedByAvailableTypes() {
        assertEquals(4, sample().top(100).size());
    }

    @Test void nonPositiveTopIsEmpty() {
        assertTrue(sample().top(0).isEmpty());
        assertTrue(sample().top(-5).isEmpty());
    }

    @Test void emptyCensus() {
        EntityCensus c = new EntityCensus();
        assertEquals(0, c.total());
        assertTrue(c.top(5).isEmpty());
    }
}
