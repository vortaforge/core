package com.vortaforge.chatguard;

// AI-assisted: written with Claude (Anthropic). See CREDITS.md at the repo root.

import static org.junit.jupiter.api.Assertions.*;

import org.junit.jupiter.api.Test;

class ChatGuardSettingsTest {

    @Test void defaultsAreValid() {
        ChatGuardSettings s = new ChatGuardSettings().sanitized();
        assertEquals(5, s.maxMessages);
        assertEquals(6, s.windowSeconds);
        assertEquals(30, s.duplicateSeconds);
        assertTrue(s.exemptOperators);
    }

    @Test void clampsNumbers() {
        ChatGuardSettings s = new ChatGuardSettings();
        s.maxMessages = -4;
        s.windowSeconds = Integer.MAX_VALUE;
        s.duplicateSeconds = -1;
        s.maxLength = 3;
        ChatGuardSettings c = s.sanitized();
        assertEquals(1, c.maxMessages);
        assertEquals(ChatGuardSettings.MAX_WINDOW_SECONDS, c.windowSeconds);
        assertEquals(0, c.duplicateSeconds);
        assertEquals(ChatGuardSettings.MIN_LENGTH, c.maxLength);
        s.maxLength = 100_000;
        assertEquals(ChatGuardSettings.MAX_LENGTH, s.sanitized().maxLength);
    }

    @Test void sanitizedValuesAlwaysBuildALimiter() {
        int[] samples = {Integer.MIN_VALUE, -1, 0, 1, 5, 600, 601, Integer.MAX_VALUE};
        for (int a : samples) for (int b : samples) for (int c : samples) {
            ChatGuardSettings s = new ChatGuardSettings();
            s.maxMessages = a;
            s.windowSeconds = b;
            s.maxLength = c;
            ChatGuardSettings x = s.sanitized();
            new ChatLimiter<String>(x.maxMessages, x.windowSeconds * 1000L, x.duplicateSeconds * 1000L, x.maxLength, 16);
        }
    }

    @Test void blankOrHugeMessagesFallBack() {
        ChatGuardSettings s = new ChatGuardSettings();
        s.tooFastMessage = null;
        s.duplicateMessage = "  ";
        s.tooLongMessage = "y".repeat(999);
        ChatGuardSettings c = s.sanitized();
        assertEquals(new ChatGuardSettings().tooFastMessage, c.tooFastMessage);
        assertEquals(new ChatGuardSettings().duplicateMessage, c.duplicateMessage);
        assertEquals(200, c.tooLongMessage.length());
    }
}
