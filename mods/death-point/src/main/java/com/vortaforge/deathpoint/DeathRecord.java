package com.vortaforge.deathpoint;

// AI-assisted: written with Claude (Anthropic). See CREDITS.md at the repo root.

import java.util.Locale;

/** Where a player last died. Minecraft-free: the dimension is the registry id as a string. */
public record DeathRecord(String dimension, int x, int y, int z) {

    /** {@code "12, 64, -30 in the Overworld"}. */
    public String describe() {
        return x + ", " + y + ", " + z + " in " + friendlyDimension(dimension);
    }

    /**
     * {@code minecraft:the_nether} becomes {@code The Nether}; ids from other namespaces
     * (modded dimensions) are shown unchanged so they stay unambiguous.
     */
    static String friendlyDimension(String id) {
        if (id == null || id.isBlank()) return "an unknown dimension";
        String prefix = "minecraft:";
        if (!id.startsWith(prefix)) return id;
        String[] words = id.substring(prefix.length()).split("_");
        StringBuilder out = new StringBuilder();
        for (String w : words) {
            if (w.isEmpty()) continue;
            if (out.length() > 0) out.append(' ');
            out.append(w.substring(0, 1).toUpperCase(Locale.ROOT)).append(w.substring(1));
        }
        String name = out.toString();
        return name.equals("Overworld") ? "the Overworld" : name.isEmpty() ? id : name;
    }
}
