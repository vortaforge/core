package com.vortaforge.homemanager;

// AI-assisted: written with Claude (Anthropic). See CREDITS.md at the repo root.

import static org.junit.jupiter.api.Assertions.*;

import org.junit.jupiter.api.Test;

class HomeSettingsTest {

    @Test void defaultIsValid() {
        assertEquals(3, new HomeSettings().sanitized().maxHomes);
    }

    @Test void clamps() {
        HomeSettings s = new HomeSettings();
        s.maxHomes = 0;
        assertEquals(1, s.sanitized().maxHomes);
        s.maxHomes = Integer.MAX_VALUE;
        assertEquals(HomeSettings.MAX_HOMES_LIMIT, s.sanitized().maxHomes);
        s.maxHomes = Integer.MIN_VALUE;
        assertEquals(1, s.sanitized().maxHomes);
    }
}
