package com.vortaforge.lagreport;

// AI-assisted: written with Claude (Anthropic). See CREDITS.md at the repo root.

import java.util.ArrayList;
import java.util.HashMap;
import java.util.List;
import java.util.Map;

/** Counts entities by type id. Minecraft-free: the caller feeds it the id strings. */
final class EntityCensus {

    record Count(String type, int count) {}

    private final Map<String, Integer> counts = new HashMap<>();
    private int total;

    void add(String typeId) {
        counts.merge(typeId, 1, Integer::sum);
        total++;
    }

    int total() {
        return total;
    }

    /** The {@code n} most common types, highest count first, ties broken by type id so output is stable. */
    List<Count> top(int n) {
        List<Count> all = new ArrayList<>(counts.size());
        counts.forEach((type, count) -> all.add(new Count(type, count)));
        all.sort((a, b) -> a.count() != b.count() ? Integer.compare(b.count(), a.count()) : a.type().compareTo(b.type()));
        return all.subList(0, Math.max(0, Math.min(n, all.size())));
    }
}
