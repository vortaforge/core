package com.vortaforge.homemanager;

// AI-assisted: written with Claude (Anthropic). See CREDITS.md at the repo root.

/** Plain settings object (public fields for Gson); {@link #sanitized()} clamps everything before use. */
public final class HomeSettings {

    public static final int MAX_HOMES_LIMIT = 50;

    /** Homes a single player may have. Lowering it never deletes existing homes. */
    public int maxHomes = 3;

    public HomeSettings sanitized() {
        HomeSettings s = new HomeSettings();
        s.maxHomes = Math.max(1, Math.min(MAX_HOMES_LIMIT, maxHomes));
        return s;
    }
}
