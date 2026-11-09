package com.vortaforge.chatguard;

// AI-assisted: written with Claude (Anthropic). See CREDITS.md at the repo root.

import static com.vortaforge.chatguard.ChatLimiter.Verdict.*;
import static org.junit.jupiter.api.Assertions.*;

import org.junit.jupiter.api.Test;

class ChatLimiterTest {

    private static ChatLimiter<String> limiter() {
        return new ChatLimiter<>(3, 10_000, 30_000, 50, 100);
    }

    @Test void allowsUpToMaxMessagesPerWindow() {
        ChatLimiter<String> l = limiter();
        assertEquals(ALLOW, l.check("a", "one", 0));
        assertEquals(ALLOW, l.check("a", "two", 1_000));
        assertEquals(ALLOW, l.check("a", "three", 2_000));
        assertEquals(TOO_FAST, l.check("a", "four", 3_000));
    }

    @Test void windowSlidesAndFreesSender() {
        ChatLimiter<String> l = limiter();
        l.check("a", "one", 0);
        l.check("a", "two", 1_000);
        l.check("a", "three", 2_000);
        assertEquals(TOO_FAST, l.check("a", "four", 9_999));
        assertEquals(ALLOW, l.check("a", "four", 10_000));   // "one" (t=0) has aged out
    }

    @Test void rejectedMessagesDoNotExtendThePenalty() {
        ChatLimiter<String> l = limiter();
        l.check("a", "one", 0);
        l.check("a", "two", 0);
        l.check("a", "three", 0);
        for (int t = 1_000; t < 10_000; t += 1_000) assertEquals(TOO_FAST, l.check("a", "spam" + t, t));
        assertEquals(ALLOW, l.check("a", "free again", 10_000));
    }

    @Test void sendersAreIndependent() {
        ChatLimiter<String> l = limiter();
        for (int i = 0; i < 3; i++) l.check("a", "m" + i, 0);
        assertEquals(TOO_FAST, l.check("a", "x", 1));
        assertEquals(ALLOW, l.check("b", "x", 1));
    }

    @Test void duplicateIsCaseAndWhitespaceInsensitive() {
        ChatLimiter<String> l = limiter();
        assertEquals(ALLOW, l.check("a", "Hello  World", 0));
        assertEquals(DUPLICATE, l.check("a", "  hello world ", 5_000));
        assertEquals(ALLOW, l.check("a", "hello there", 6_000));
    }

    @Test void duplicateExpires() {
        ChatLimiter<String> l = limiter();
        assertEquals(ALLOW, l.check("a", "gg", 0));
        assertEquals(DUPLICATE, l.check("a", "gg", 29_999));
        assertEquals(ALLOW, l.check("a", "gg", 30_000));
    }

    @Test void duplicateCheckCanBeDisabled() {
        ChatLimiter<String> l = new ChatLimiter<>(5, 10_000, 0, 50, 100);
        assertEquals(ALLOW, l.check("a", "gg", 0));
        assertEquals(ALLOW, l.check("a", "gg", 1));
    }

    @Test void rejectedDuplicateIsNotCountedTowardsTheRate() {
        ChatLimiter<String> l = limiter();
        l.check("a", "gg", 0);
        for (int i = 1; i <= 10; i++) assertEquals(DUPLICATE, l.check("a", "gg", i));
        assertEquals(ALLOW, l.check("a", "other 1", 20));
        assertEquals(ALLOW, l.check("a", "other 2", 21));
        assertEquals(TOO_FAST, l.check("a", "other 3", 22));  // 3 accepted so far: gg, other 1, other 2
    }

    @Test void tooLongIsRejectedAndNotRecorded() {
        ChatLimiter<String> l = limiter();
        assertEquals(TOO_LONG, l.check("a", "x".repeat(51), 0));
        assertEquals(ALLOW, l.check("a", "x".repeat(50), 0));
    }

    @Test void trackedSendersAreBounded() {
        ChatLimiter<Integer> l = new ChatLimiter<>(3, 10_000, 0, 50, 4);
        for (int i = 0; i < 100; i++) l.check(i, "hi", 0);
        assertEquals(4, l.trackedCount());
    }

    @Test void removeForgetsSender() {
        ChatLimiter<String> l = limiter();
        l.check("a", "x", 0);
        l.remove("a");
        assertEquals(0, l.trackedCount());
        assertEquals(ALLOW, l.check("a", "x", 1));
    }

    @Test void rejectsInvalidParameters() {
        assertThrows(IllegalArgumentException.class, () -> new ChatLimiter<String>(0, 1, 0, 1, 1));
        assertThrows(IllegalArgumentException.class, () -> new ChatLimiter<String>(1, 0, 0, 1, 1));
        assertThrows(IllegalArgumentException.class, () -> new ChatLimiter<String>(1, 1, -1, 1, 1));
        assertThrows(IllegalArgumentException.class, () -> new ChatLimiter<String>(1, 1, 0, 0, 1));
        assertThrows(IllegalArgumentException.class, () -> new ChatLimiter<String>(1, 1, 0, 1, 0));
    }
}
