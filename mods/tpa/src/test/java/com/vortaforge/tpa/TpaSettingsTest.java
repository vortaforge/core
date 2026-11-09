package com.vortaforge.tpa;

// AI-assisted: written with Claude (Anthropic). See CREDITS.md at the repo root.

import static org.junit.jupiter.api.Assertions.*;

import org.junit.jupiter.api.Test;

class TpaSettingsTest {

    @Test void defaultsAreValid() {
        TpaSettings s = new TpaSettings().sanitized();
        assertEquals(60, s.expirySeconds);
        assertEquals(10, s.cooldownSeconds);
        assertTrue(s.allowCrossDimension);
    }

    @Test void clampsValues() {
        TpaSettings s = new TpaSettings();
        s.expirySeconds = -5;
        s.cooldownSeconds = Integer.MAX_VALUE;
        TpaSettings c = s.sanitized();
        assertEquals(TpaSettings.MIN_EXPIRY_SECONDS, c.expirySeconds);
        assertEquals(TpaSettings.MAX_COOLDOWN_SECONDS, c.cooldownSeconds);
        s.expirySeconds = Integer.MAX_VALUE;
        s.cooldownSeconds = -1;
        assertEquals(TpaSettings.MAX_EXPIRY_SECONDS, s.sanitized().expirySeconds);
        assertEquals(0, s.sanitized().cooldownSeconds);
    }

    @Test void sanitizedValuesAlwaysBuildARequestBook() {
        int[] samples = {Integer.MIN_VALUE, -1, 0, 1, 10, 600, 601, Integer.MAX_VALUE};
        for (int e : samples) for (int c : samples) {
            TpaSettings s = new TpaSettings();
            s.expirySeconds = e;
            s.cooldownSeconds = c;
            TpaSettings x = s.sanitized();
            new RequestBook<String>(x.expirySeconds * 1000L, x.cooldownSeconds * 1000L, 16);
        }
    }
}
