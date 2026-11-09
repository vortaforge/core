package com.vortaforge.deathpoint;

// AI-assisted: written with Claude (Anthropic). See CREDITS.md at the repo root.

import java.util.LinkedHashMap;
import java.util.Map;

/** Latest {@link DeathRecord} per player, bounded so a long-running server cannot grow it without limit. */
final class DeathBook<K> {

    private final Map<K, DeathRecord> records;

    DeathBook(int maxEntries) {
        if (maxEntries < 1) throw new IllegalArgumentException("maxEntries must be >= 1");
        this.records = new LinkedHashMap<>(16, 0.75f, true) {
            @Override
            protected boolean removeEldestEntry(Map.Entry<K, DeathRecord> eldest) {
                return size() > maxEntries;
            }
        };
    }

    synchronized void record(K player, DeathRecord record) {
        records.put(player, record);
    }

    /** Latest death of {@code player}, or {@code null} if none was recorded since the server started. */
    synchronized DeathRecord last(K player) {
        return records.get(player);
    }

    synchronized int size() {
        return records.size();
    }
}
