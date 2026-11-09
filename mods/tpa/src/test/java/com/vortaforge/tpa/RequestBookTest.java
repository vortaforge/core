package com.vortaforge.tpa;

// AI-assisted: written with Claude (Anthropic). See CREDITS.md at the repo root.

import static org.junit.jupiter.api.Assertions.*;

import org.junit.jupiter.api.Test;

class RequestBookTest {

    private static RequestBook<String> book() {
        return new RequestBook<>(60_000, 10_000, 100);
    }

    @Test void requestThenTakeReturnsSender() {
        RequestBook<String> b = book();
        assertEquals(RequestBook.Verdict.OK, b.request("alice", "bob", 0).verdict());
        assertEquals("alice", b.take("bob", 1_000));
        assertNull(b.take("bob", 1_001));          // consumed
    }

    @Test void cannotRequestYourself() {
        assertEquals(RequestBook.Verdict.SELF, book().request("a", "a", 0).verdict());
    }

    @Test void cooldownBlocksAndReportsRemainingTime() {
        RequestBook<String> b = book();
        b.request("a", "b", 0);
        RequestBook.Result r = b.request("a", "c", 4_000);
        assertEquals(RequestBook.Verdict.COOLDOWN, r.verdict());
        assertEquals(6_000, r.retryAfterMillis());
        assertEquals(RequestBook.Verdict.OK, b.request("a", "c", 10_000).verdict());
    }

    @Test void rejectedRequestsDoNotRestartTheCooldown() {
        RequestBook<String> b = book();
        b.request("a", "b", 0);
        b.request("a", "c", 5_000);                // rejected
        assertEquals(RequestBook.Verdict.OK, b.request("a", "c", 10_000).verdict());
    }

    @Test void selfRequestDoesNotStartCooldown() {
        RequestBook<String> b = book();
        b.request("a", "a", 0);
        assertEquals(RequestBook.Verdict.OK, b.request("a", "b", 1).verdict());
    }

    @Test void newRequestReplacesSendersOldOne() {
        RequestBook<String> b = new RequestBook<>(60_000, 0, 100);
        b.request("a", "b", 0);
        b.request("a", "c", 1);
        assertNull(b.take("b", 2));
        assertEquals("a", b.take("c", 2));
    }

    @Test void requestsExpire() {
        RequestBook<String> b = book();
        b.request("a", "b", 0);
        assertNull(b.take("b", 60_000));
        assertEquals(0, b.pendingCount(60_000));
    }

    @Test void justBeforeExpiryStillWorks() {
        RequestBook<String> b = book();
        b.request("a", "b", 0);
        assertEquals("a", b.take("b", 59_999));
    }

    @Test void newestRequestToATargetIsAnsweredFirst() {
        RequestBook<String> b = new RequestBook<>(60_000, 0, 100);
        b.request("a", "t", 0);
        b.request("c", "t", 5);
        assertEquals("c", b.take("t", 10));
        assertEquals("a", b.take("t", 10));
        assertNull(b.take("t", 10));
    }

    @Test void cancelRemovesOnlyOwnRequest() {
        RequestBook<String> b = new RequestBook<>(60_000, 0, 100);
        b.request("a", "t", 0);
        b.request("c", "t", 1);
        assertTrue(b.cancel("a", 2));
        assertFalse(b.cancel("a", 2));
        assertEquals("c", b.take("t", 3));
    }

    @Test void forgetDropsRequestsFromAndToAPlayer() {
        RequestBook<String> b = new RequestBook<>(60_000, 0, 100);
        b.request("a", "x", 0);       // from x's perspective: a -> x
        b.request("x", "b", 0);       // x -> b
        b.request("c", "d", 0);       // unrelated
        b.forget("x");
        assertNull(b.take("x", 1));
        assertNull(b.take("b", 1));
        assertEquals("c", b.take("d", 1));
    }

    @Test void forgetAlsoClearsCooldown() {
        RequestBook<String> b = book();
        b.request("a", "b", 0);
        b.forget("a");
        assertEquals(RequestBook.Verdict.OK, b.request("a", "b", 1).verdict());
    }

    @Test void cooldownMemoryIsBounded() {
        RequestBook<Integer> b = new RequestBook<>(60_000, 10_000, 3);
        for (int i = 0; i < 50; i++) b.request(i, i + 1000, 0);
        // The oldest senders were forgotten, so they are no longer on cooldown; the newest still are.
        assertEquals(RequestBook.Verdict.OK, b.request(0, 5000, 1).verdict());
        assertEquals(RequestBook.Verdict.COOLDOWN, b.request(49, 5000, 1).verdict());
    }

    @Test void rejectsInvalidParameters() {
        assertThrows(IllegalArgumentException.class, () -> new RequestBook<String>(0, 0, 1));
        assertThrows(IllegalArgumentException.class, () -> new RequestBook<String>(1, -1, 1));
        assertThrows(IllegalArgumentException.class, () -> new RequestBook<String>(1, 0, 0));
    }
}
