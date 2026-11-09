package com.vortaforge.chatguard;

// AI-assisted: written with Claude (Anthropic). See CREDITS.md at the repo root.

/** Plain settings object (public fields for Gson); {@link #sanitized()} clamps everything before use. */
public final class ChatGuardSettings {

    public static final int MAX_MESSAGES_LIMIT = 100;
    public static final int MAX_WINDOW_SECONDS = 600;
    public static final int MAX_DUPLICATE_SECONDS = 3_600;
    public static final int MIN_LENGTH = 16;
    /** Vanilla's own hard cap for a chat message. */
    public static final int MAX_LENGTH = 256;

    public int maxMessages = 5;
    public int windowSeconds = 6;
    /** 0 = do not reject repeated messages. */
    public int duplicateSeconds = 30;
    public int maxLength = 256;
    public boolean exemptOperators = true;
    public String tooFastMessage = "You are chatting too fast.";
    public String duplicateMessage = "Please do not repeat the same message.";
    public String tooLongMessage = "That message is too long.";

    public ChatGuardSettings sanitized() {
        ChatGuardSettings s = new ChatGuardSettings();
        s.maxMessages = clamp(maxMessages, 1, MAX_MESSAGES_LIMIT);
        s.windowSeconds = clamp(windowSeconds, 1, MAX_WINDOW_SECONDS);
        s.duplicateSeconds = clamp(duplicateSeconds, 0, MAX_DUPLICATE_SECONDS);
        s.maxLength = clamp(maxLength, MIN_LENGTH, MAX_LENGTH);
        s.exemptOperators = exemptOperators;
        s.tooFastMessage = text(tooFastMessage, new ChatGuardSettings().tooFastMessage);
        s.duplicateMessage = text(duplicateMessage, new ChatGuardSettings().duplicateMessage);
        s.tooLongMessage = text(tooLongMessage, new ChatGuardSettings().tooLongMessage);
        return s;
    }

    private static int clamp(int v, int lo, int hi) {
        return Math.max(lo, Math.min(hi, v));
    }

    private static String text(String v, String fallback) {
        String m = (v == null || v.isBlank()) ? fallback : v;
        return m.length() > 200 ? m.substring(0, 200) : m;
    }
}
