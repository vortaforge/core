package com.vortaforge.tpa;

// AI-assisted: written with Claude (Anthropic). See CREDITS.md at the repo root.

/** Plain settings object (public fields for Gson); {@link #sanitized()} clamps everything before use. */
public final class TpaSettings {

    public static final int MIN_EXPIRY_SECONDS = 10;
    public static final int MAX_EXPIRY_SECONDS = 600;
    public static final int MAX_COOLDOWN_SECONDS = 3_600;

    public int expirySeconds = 60;
    public int cooldownSeconds = 10;
    /** Allow a request to move the sender into another dimension. */
    public boolean allowCrossDimension = true;

    public TpaSettings sanitized() {
        TpaSettings s = new TpaSettings();
        s.expirySeconds = Math.max(MIN_EXPIRY_SECONDS, Math.min(MAX_EXPIRY_SECONDS, expirySeconds));
        s.cooldownSeconds = Math.max(0, Math.min(MAX_COOLDOWN_SECONDS, cooldownSeconds));
        s.allowCrossDimension = allowCrossDimension;
        return s;
    }
}
