package com.vortaforge.lagreport;

// AI-assisted: written with Claude (Anthropic). See CREDITS.md at the repo root.

import static org.junit.jupiter.api.Assertions.*;

import org.junit.jupiter.api.Test;

class TpsTest {

    @Test void fastTicksAreCappedAtTwenty() {
        assertEquals(20.0, Tps.fromMspt(10.0), 1e-9);
        assertEquals(20.0, Tps.fromMspt(50.0), 1e-9);
    }

    @Test void slowTicksLowerTps() {
        assertEquals(10.0, Tps.fromMspt(100.0), 1e-9);
        assertEquals(1000.0 / 75.0, Tps.fromMspt(75.0), 1e-9);
    }

    @Test void garbageInputReadsAsHealthy() {
        assertEquals(20.0, Tps.fromMspt(0), 1e-9);
        assertEquals(20.0, Tps.fromMspt(-3), 1e-9);
        assertEquals(20.0, Tps.fromMspt(Double.NaN), 1e-9);
        assertEquals(20.0, Tps.fromMspt(Double.POSITIVE_INFINITY), 1e-9);
    }

    @Test void statusSwitchesAboveTheBudget() {
        assertEquals("OK", Tps.status(49.9));
        assertEquals("OK", Tps.status(50.0));
        assertEquals("BEHIND", Tps.status(50.1));
        assertEquals("OK", Tps.status(Double.NaN));
    }
}
