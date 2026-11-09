package com.vortaforge.lagreport;

// AI-assisted: written with Claude (Anthropic). See CREDITS.md at the repo root.

/** Tick-time arithmetic. Minecraft aims for 50 ms per tick (20 TPS) and never runs faster than that. */
final class Tps {

    static final double TARGET_MSPT = 50.0;
    static final double MAX_TPS = 20.0;

    private Tps() {}

    /** TPS implied by an average tick time in milliseconds, capped at 20. Non-finite or non-positive input reads as 20. */
    static double fromMspt(double mspt) {
        if (!Double.isFinite(mspt) || mspt <= 0) return MAX_TPS;
        return Math.min(MAX_TPS, 1000.0 / mspt);
    }

    /** {@code OK} within the 50 ms budget, {@code BEHIND} when ticks take longer than that. */
    static String status(double mspt) {
        return (Double.isFinite(mspt) && mspt > TARGET_MSPT) ? "BEHIND" : "OK";
    }
}
