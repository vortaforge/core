package com.vortaforge.lagreport;

// AI-assisted: written with Claude (Anthropic). See CREDITS.md at the repo root.

/** Plain settings object (public fields for Gson); {@link #sanitized()} clamps everything before use. */
public final class LagReportSettings {

    public static final int MAX_TOP = 20;

    /** How many entity types to list per dimension. */
    public int topEntityTypes = 5;
    /** Vanilla permission level needed for {@code /lag}: 0 = everyone, 2 = operators (default), 4 = owners. */
    public int permissionLevel = 2;

    public LagReportSettings sanitized() {
        LagReportSettings s = new LagReportSettings();
        s.topEntityTypes = Math.max(1, Math.min(MAX_TOP, topEntityTypes));
        s.permissionLevel = Math.max(0, Math.min(4, permissionLevel));
        return s;
    }
}
