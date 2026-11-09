package com.vortaforge.homemanager;

// AI-assisted: written with Claude (Anthropic). See CREDITS.md at the repo root.

import java.util.ArrayList;
import java.util.Collections;
import java.util.LinkedHashMap;
import java.util.List;
import java.util.Locale;
import java.util.Map;
import java.util.TreeMap;
import java.util.regex.Pattern;

/**
 * Named homes per owner. Minecraft-free: owners are plain strings (the player UUID as text).
 *
 * <p>Home names are case-insensitive, 1 to 16 characters of {@code a-z 0-9 _ -}. The per-owner limit
 * only blocks <em>new</em> homes: lowering it later never deletes homes a player already has.
 */
final class HomeBook {

    enum SetResult { CREATED, REPLACED, LIMIT, BAD_NAME }

    static final int MAX_NAME_LENGTH = 16;
    private static final Pattern VALID_NAME = Pattern.compile("[a-z0-9_-]{1," + MAX_NAME_LENGTH + "}");

    private final int maxHomes;
    private final Map<String, Map<String, Home>> byOwner = new LinkedHashMap<>();

    HomeBook(int maxHomes) {
        if (maxHomes < 1) throw new IllegalArgumentException("maxHomes must be >= 1");
        this.maxHomes = maxHomes;
    }

    /** Lower-cased name if valid, otherwise {@code null}. */
    static String normalizeName(String raw) {
        if (raw == null) return null;
        String name = raw.strip().toLowerCase(Locale.ROOT);
        return VALID_NAME.matcher(name).matches() ? name : null;
    }

    synchronized SetResult set(String owner, String rawName, Home home) {
        String name = normalizeName(rawName);
        if (name == null) return SetResult.BAD_NAME;
        Map<String, Home> homes = byOwner.computeIfAbsent(owner, o -> new TreeMap<>());
        boolean existed = homes.containsKey(name);
        if (!existed && homes.size() >= maxHomes) {
            if (homes.isEmpty()) byOwner.remove(owner);
            return SetResult.LIMIT;
        }
        homes.put(name, home);
        return existed ? SetResult.REPLACED : SetResult.CREATED;
    }

    synchronized Home get(String owner, String rawName) {
        String name = normalizeName(rawName);
        Map<String, Home> homes = byOwner.get(owner);
        return (name == null || homes == null) ? null : homes.get(name);
    }

    synchronized boolean delete(String owner, String rawName) {
        String name = normalizeName(rawName);
        Map<String, Home> homes = byOwner.get(owner);
        if (name == null || homes == null || homes.remove(name) == null) return false;
        if (homes.isEmpty()) byOwner.remove(owner);
        return true;
    }

    /** The owner's home names in alphabetical order. */
    synchronized List<String> names(String owner) {
        Map<String, Home> homes = byOwner.get(owner);
        return homes == null ? List.of() : new ArrayList<>(homes.keySet());
    }

    synchronized int limit() {
        return maxHomes;
    }

    /** Deep copy for persistence. */
    synchronized Map<String, Map<String, Home>> snapshot() {
        Map<String, Map<String, Home>> copy = new LinkedHashMap<>();
        byOwner.forEach((owner, homes) -> copy.put(owner, Collections.unmodifiableMap(new TreeMap<>(homes))));
        return copy;
    }

    /**
     * Rebuilds a book from stored data. Entries with an invalid name or a null home are skipped; the
     * per-owner limit is deliberately not applied, so existing homes survive a lowered limit.
     */
    static HomeBook restore(int maxHomes, Map<String, Map<String, Home>> stored) {
        HomeBook book = new HomeBook(maxHomes);
        if (stored == null) return book;
        stored.forEach((owner, homes) -> {
            if (owner == null || homes == null) return;
            Map<String, Home> clean = new TreeMap<>();
            homes.forEach((rawName, home) -> {
                String name = normalizeName(rawName);
                if (name != null && home != null && home.dimension() != null) clean.put(name, home);
            });
            if (!clean.isEmpty()) book.byOwner.put(owner, clean);
        });
        return book;
    }
}
