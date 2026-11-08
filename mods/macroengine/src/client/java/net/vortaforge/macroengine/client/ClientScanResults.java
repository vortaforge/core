package net.vortaforge.macroengine.client;

import net.vortaforge.macroengine.ack.ArchiveRegistry;
import net.vortaforge.macroengine.validate.PackScanner;
import net.vortaforge.macroengine.validate.SuspiciousText;

import java.util.List;
import java.util.concurrent.atomic.AtomicReference;

/**
 * The client's copy of the last scan.
 *
 * <p>Kept separate from the server-side holder on purpose: on a multiplayer client
 * the server's scan is not visible, and merging the two would let a single-player
 * result leak into a multiplayer session or the other way round.
 */
public final class ClientScanResults {
    private static final org.slf4j.Logger LOG =
            org.slf4j.LoggerFactory.getLogger("macroengine-client");
    private static final AtomicReference<PackScanner.Report> CURRENT = new AtomicReference<>(null);

    private ClientScanResults() {
    }

    public static void publish(PackScanner.Report report) {
        CURRENT.set(report);
    }

    /** Record a scan that could not run, without pretending it was clean. */
    public static void publishFailure(String reason) {
        CURRENT.set(new PackScanner.Report(0, 0, List.of(), List.of(), List.of(reason), List.of()));
    }

    public static PackScanner.Report current() {
        PackScanner.Report report = CURRENT.get();
        if (report != null) {
            return report;
        }
        return new PackScanner.Report(0, 0, List.of(), List.of(),
                List.of("the content check has not run yet"), List.of());
    }

    /**
     * Content hash for a pack, or null when the client cannot obtain one.
     *
     * <p><b>Unverified for 26.3.</b> The client resource manager is consulted for a
     * path to the pack; if it does not expose one, this returns null and the pack
     * is silently skipped rather than shown as a prompt that could never be
     * satisfied. The honest fix is a {@code ContentHash} overload that hashes
     * {@code (name, bytes)} pairs straight out of the resource manager; see the
     * note in {@code MacroEngineClient}.
     */
    public static String hashOf(String packId) {
        // Deliberately returning null rather than guessing at an accessor. A wrong
        // guess here would hash the wrong bytes and produce an acknowledgement that
        // never matches what the server computed.
        //
        // A null here means the client-side prompt never fires. That is a silent
        // failure, so it says so once in the log rather than looking like a clean
        // world.
        if (HASH_UNSUPPORTED_LOGGED.compareAndSet(false, true)) {
            ClientScanResults.LOG.warn(
                    "macroEngine: client-side pack hashing is not implemented for this build, so the "
                            + "client prompt will not fire. The server-side /macroengine ack flow is "
                            + "unaffected.");
        }
        return null;
    }

    private static final java.util.concurrent.atomic.AtomicBoolean HASH_UNSUPPORTED_LOGGED =
            new java.util.concurrent.atomic.AtomicBoolean(false);

    /** True when the pack is in the archive registry at this hash. */
    public static boolean isArchived(String packId, String hash) {
        return ArchiveRegistry.get().byContentHash(hash).isPresent();
    }

    public static boolean hasProblems() {
        PackScanner.Report report = current();
        return !report.findings().isEmpty()
                || !report.metaProblems().isEmpty()
                || report.count(SuspiciousText.Severity.HIGH) > 0;
    }
}
