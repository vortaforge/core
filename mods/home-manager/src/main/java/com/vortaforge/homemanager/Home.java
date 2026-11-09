package com.vortaforge.homemanager;

// AI-assisted: written with Claude (Anthropic). See CREDITS.md at the repo root.

/** A saved position. The dimension is the registry id as a string, e.g. {@code minecraft:overworld}. */
public record Home(String dimension, double x, double y, double z, float yaw, float pitch) {}
