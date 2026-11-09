package com.vortaforge.deathpoint;

// AI-assisted: written with Claude (Anthropic). See CREDITS.md at the repo root.

/** Plain settings object (public fields for Gson); {@link #sanitized()} normalises it before use. */
public final class DeathPointSettings {

    /** Tell the player their death location in chat right when they die. */
    public boolean announce = true;
    /** Register {@code /deathpos}. */
    public boolean enableCommand = true;

    public DeathPointSettings sanitized() {
        DeathPointSettings s = new DeathPointSettings();
        s.announce = announce;
        s.enableCommand = enableCommand;
        return s;
    }
}
