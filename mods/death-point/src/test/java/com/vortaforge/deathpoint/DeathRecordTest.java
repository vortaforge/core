package com.vortaforge.deathpoint;

// AI-assisted: written with Claude (Anthropic). See CREDITS.md at the repo root.

import static org.junit.jupiter.api.Assertions.*;

import org.junit.jupiter.api.Test;

class DeathRecordTest {

    @Test void describesVanillaDimensions() {
        assertEquals("12, 64, -30 in the Overworld", new DeathRecord("minecraft:overworld", 12, 64, -30).describe());
        assertEquals("0, 70, 0 in The Nether", new DeathRecord("minecraft:the_nether", 0, 70, 0).describe());
        assertEquals("1, 2, 3 in The End", new DeathRecord("minecraft:the_end", 1, 2, 3).describe());
    }

    @Test void keepsModdedDimensionIdsUnchanged() {
        assertEquals("5, 5, 5 in othermod:sky_island", new DeathRecord("othermod:sky_island", 5, 5, 5).describe());
    }

    @Test void survivesMissingDimension() {
        assertEquals("1, 1, 1 in an unknown dimension", new DeathRecord(null, 1, 1, 1).describe());
        assertEquals("1, 1, 1 in an unknown dimension", new DeathRecord(" ", 1, 1, 1).describe());
    }

    @Test void negativeCoordinatesArePrintedAsIs() {
        assertTrue(new DeathRecord("minecraft:overworld", -1, -64, -2).describe().startsWith("-1, -64, -2"));
    }
}
