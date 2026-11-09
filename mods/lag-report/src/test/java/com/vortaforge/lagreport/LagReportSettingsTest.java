package com.vortaforge.lagreport;

// AI-assisted: written with Claude (Anthropic). See CREDITS.md at the repo root.

import static org.junit.jupiter.api.Assertions.*;

import org.junit.jupiter.api.Test;

class LagReportSettingsTest {

    @Test void defaultsAreValid() {
        LagReportSettings s = new LagReportSettings().sanitized();
        assertEquals(5, s.topEntityTypes);
        assertEquals(2, s.permissionLevel);
    }

    @Test void clampsValues() {
        LagReportSettings s = new LagReportSettings();
        s.topEntityTypes = 0;
        s.permissionLevel = 99;
        assertEquals(1, s.sanitized().topEntityTypes);
        assertEquals(4, s.sanitized().permissionLevel);
        s.topEntityTypes = 1_000;
        s.permissionLevel = -1;
        assertEquals(LagReportSettings.MAX_TOP, s.sanitized().topEntityTypes);
        assertEquals(0, s.sanitized().permissionLevel);
    }
}
