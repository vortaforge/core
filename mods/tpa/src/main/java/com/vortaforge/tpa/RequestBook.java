package com.vortaforge.tpa;

// AI-assisted: written with Claude (Anthropic). See CREDITS.md at the repo root.

import java.util.HashMap;
import java.util.Iterator;
import java.util.LinkedHashMap;
import java.util.Map;

/**
 * Pending teleport requests. Minecraft-free: callers pass player keys and the current time in
 * milliseconds.
 *
 * <p>Rules: one pending request per sender (a new one replaces the old one), requests expire after
 * {@code expiryMillis}, and a sender must wait {@code cooldownMillis} between requests. Expired
 * requests are dropped lazily on every call.
 */
final class RequestBook<K> {

    enum Verdict { OK, SELF, COOLDOWN }

    record Result(Verdict verdict, long retryAfterMillis) {}

    private record Pending<K>(K target, long createdAt) {}

    private final long expiryMillis;
    private final long cooldownMillis;
    private final Map<K, Pending<K>> bySender = new LinkedHashMap<>();
    private final Map<K, Long> lastRequestAt;

    RequestBook(long expiryMillis, long cooldownMillis, int maxCooldownEntries) {
        if (expiryMillis <= 0 || cooldownMillis < 0 || maxCooldownEntries < 1) {
            throw new IllegalArgumentException("invalid request book parameters");
        }
        this.expiryMillis = expiryMillis;
        this.cooldownMillis = cooldownMillis;
        this.lastRequestAt = new LinkedHashMap<>(16, 0.75f, true) {
            @Override
            protected boolean removeEldestEntry(Map.Entry<K, Long> eldest) {
                return size() > maxCooldownEntries;
            }
        };
    }

    synchronized Result request(K sender, K target, long now) {
        purgeExpired(now);
        if (sender.equals(target)) return new Result(Verdict.SELF, 0);

        Long last = lastRequestAt.get(sender);
        if (last != null && now - last < cooldownMillis) {
            return new Result(Verdict.COOLDOWN, cooldownMillis - (now - last));
        }
        lastRequestAt.put(sender, now);
        bySender.put(sender, new Pending<>(target, now));
        return new Result(Verdict.OK, 0);
    }

    /** Removes and returns the sender of the newest live request addressed to {@code target}, or null. */
    synchronized K take(K target, long now) {
        purgeExpired(now);
        K best = null;
        long bestAt = Long.MIN_VALUE;
        for (Map.Entry<K, Pending<K>> e : bySender.entrySet()) {
            if (e.getValue().target().equals(target) && e.getValue().createdAt() >= bestAt) {
                best = e.getKey();
                bestAt = e.getValue().createdAt();
            }
        }
        if (best != null) bySender.remove(best);
        return best;
    }

    /** Cancels the sender's own pending request. */
    synchronized boolean cancel(K sender, long now) {
        purgeExpired(now);
        return bySender.remove(sender) != null;
    }

    /** Drops everything involving a player who left. */
    synchronized void forget(K player) {
        bySender.remove(player);
        bySender.values().removeIf(p -> p.target().equals(player));
        lastRequestAt.remove(player);
    }

    synchronized int pendingCount(long now) {
        purgeExpired(now);
        return bySender.size();
    }

    private void purgeExpired(long now) {
        Iterator<Pending<K>> it = bySender.values().iterator();
        while (it.hasNext()) {
            if (now - it.next().createdAt() >= expiryMillis) it.remove();
        }
    }
}
