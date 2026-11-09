package com.vortaforge.chatguard;

// AI-assisted: written with Claude (Anthropic). See CREDITS.md at the repo root.

import java.util.ArrayDeque;
import java.util.LinkedHashMap;
import java.util.Locale;
import java.util.Map;

/**
 * Decides whether a chat message is acceptable. Minecraft-free: the caller passes the sender key,
 * the text and the current time in milliseconds (non-decreasing per key).
 *
 * <p>Only <em>accepted</em> messages count towards the rate window and the duplicate check, so a
 * rejected flood does not extend its own penalty: the sender is free again one window after the
 * last message that went through.
 */
final class ChatLimiter<K> {

    enum Verdict { ALLOW, TOO_LONG, DUPLICATE, TOO_FAST }

    private static final class State {
        final ArrayDeque<Long> accepted = new ArrayDeque<>();
        String lastNormalized;
        long lastAt;
    }

    private final int maxMessages;
    private final long windowMillis;
    private final long duplicateMillis;
    private final int maxLength;
    private final Map<K, State> states;

    /**
     * @param maxMessages     accepted messages allowed per window (>= 1)
     * @param windowMillis    window length (> 0)
     * @param duplicateMillis how long an identical repeat is rejected; 0 disables the check
     * @param maxLength       longest accepted message in characters (>= 1)
     * @param maxTracked      senders remembered at once; the least recently used are forgotten first
     */
    ChatLimiter(int maxMessages, long windowMillis, long duplicateMillis, int maxLength, int maxTracked) {
        if (maxMessages < 1 || windowMillis <= 0 || duplicateMillis < 0 || maxLength < 1 || maxTracked < 1) {
            throw new IllegalArgumentException("invalid limiter parameters");
        }
        this.maxMessages = maxMessages;
        this.windowMillis = windowMillis;
        this.duplicateMillis = duplicateMillis;
        this.maxLength = maxLength;
        this.states = new LinkedHashMap<>(16, 0.75f, true) {
            @Override
            protected boolean removeEldestEntry(Map.Entry<K, State> eldest) {
                return size() > maxTracked;
            }
        };
    }

    synchronized Verdict check(K sender, String message, long nowMillis) {
        if (message.length() > maxLength) return Verdict.TOO_LONG;

        State s = states.computeIfAbsent(sender, k -> new State());
        String normalized = normalize(message);

        if (duplicateMillis > 0 && normalized.equals(s.lastNormalized) && nowMillis - s.lastAt < duplicateMillis) {
            return Verdict.DUPLICATE;
        }

        while (!s.accepted.isEmpty() && nowMillis - s.accepted.peekFirst() >= windowMillis) {
            s.accepted.pollFirst();
        }
        if (s.accepted.size() >= maxMessages) return Verdict.TOO_FAST;

        s.accepted.addLast(nowMillis);
        s.lastNormalized = normalized;
        s.lastAt = nowMillis;
        return Verdict.ALLOW;
    }

    synchronized void remove(K sender) {
        states.remove(sender);
    }

    synchronized int trackedCount() {
        return states.size();
    }

    /** Case, repeated whitespace and surrounding whitespace do not make a message "different". */
    static String normalize(String message) {
        return message.strip().replaceAll("\\s+", " ").toLowerCase(Locale.ROOT);
    }
}
