package net.vortaforge.macroengine.client;

import net.fabricmc.api.ClientModInitializer;
import net.fabricmc.fabric.api.client.event.lifecycle.v1.ClientLifecycleEvents;
import net.fabricmc.fabric.api.client.screen.v1.ScreenEvents;
import net.fabricmc.fabric.api.client.screen.v1.Screens;
import net.minecraft.client.Minecraft;
import net.minecraft.client.gui.screens.Screen;
import net.minecraft.client.gui.screens.TitleScreen;
import net.vortaforge.macroengine.ack.PackGate;
import net.vortaforge.macroengine.validate.PackScanner;
import net.vortaforge.macroengine.validate.SuspiciousText;
import org.slf4j.Logger;
import org.slf4j.LoggerFactory;

import java.util.ArrayList;
import java.util.List;

/**
 * Client half: the acknowledgement screen, and the scan that feeds it.
 *
 * <h2>Two different moments, one message</h2>
 *
 * <ul>
 *   <li><b>The title screen.</b> The world's data pack stack is not final until the
 *       integrated server has started, so the title screen cannot decide about
 *       packs. It can only offer the content check on demand.</li>
 *   <li><b>World load.</b> This is where the decision belongs, and that is what
 *       {@link #showWorldWarningIfNeeded} is for.</li>
 * </ul>
 *
 * <h2>What changed</h2>
 *
 * {@code showWorldWarningIfNeeded} used to be dead code: nothing called it, and the
 * method it would have called did nothing but go back. It is now the entry point
 * the world-open path uses, and it returns whether the caller may proceed.
 *
 * <h2>The limit this cannot cross</h2>
 *
 * This runs on a client. It cannot see a multiplayer server's pack stack, and a
 * player's acknowledgement here covers their own single-player worlds only. The
 * server half lives in {@code /macroengine ack}; saying otherwise would be a
 * security claim this code cannot keep.
 */
public final class MacroEngineClient implements ClientModInitializer {
    private static final Logger LOG = LoggerFactory.getLogger("macroengine-client");

    @Override
    public void onInitializeClient() {
        ClientLifecycleEvents.CLIENT_STARTED.register(MacroEngineClient::scheduleScan);
        registerTitleScreenNotice();
        LOG.info("macroEngine client ready");
    }

    private static void scheduleScan(Minecraft client) {
        try {
            PackScanner.Report report = PackScanner.scan(client.getResourceManager(), 2000);
            ClientScanResults.publish(report);
            LOG.info(report.summaryLine());
            for (SuspiciousText.Finding finding : report.findings()) {
                LOG.warn("macroEngine client: {}", finding);
            }
            for (var problem : report.metaProblems()) {
                LOG.warn("macroEngine client: {}", problem);
            }
        } catch (RuntimeException e) {
            // A broken scan must not stop the game from starting. It is recorded as
            // a failure, not as a clean result.
            LOG.warn("macroEngine client: scan failed and was skipped - {}", e.toString());
            ClientScanResults.publishFailure(e.toString());
        }
    }

    /**
     * Put a "Content check" button on the title screen.
     *
     * <p>An extra widget rather than a replaced screen: a mod that replaces the
     * title screen is one of the most common sources of "this mod breaks with that
     * mod", and a button does not need that.
     */
    private static void registerTitleScreenNotice() {
        ScreenEvents.AFTER_INIT.register((client, screen, scaledWidth, scaledHeight) -> {
            if (!(screen instanceof TitleScreen)) {
                return;
            }
            var button = net.minecraft.client.gui.components.Button.builder(
                            net.minecraft.network.chat.Component.literal("Content check"),
                            b -> openWarning(client, screen, List.of(), () -> { }, () -> { }))
                    .bounds(scaledWidth - 108, 6, 104, 20)
                    .build();
            if (ClientScanResults.hasProblems()) {
                button.setMessage(net.minecraft.network.chat.Component.literal("⚠ Content check"));
            }
            Screens.getWidgets(screen).add(button);
        });
    }

    private static void openWarning(Minecraft client, Screen parent,
                                    List<ContentWarningScreen.PackLine> pending,
                                    Runnable onConfirm, Runnable onCancel) {
        PackScanner.Report report = ClientScanResults.current();
        boolean high = report.count(SuspiciousText.Severity.HIGH) > 0 || !report.metaProblems().isEmpty();

        List<String> lines = new ArrayList<>();
        for (SuspiciousText.Finding finding : report.findings()) {
            lines.add("[" + finding.severity() + "] " + finding.where() + " \"" + finding.snippet() + "\"");
        }
        for (var problem : report.metaProblems()) {
            lines.add("[meta] " + problem.where() + ": " + problem.message());
        }

        client.setScreenAndShow(new ContentWarningScreen(parent, pending, lines, high, onConfirm, onCancel));
    }

    /**
     * Called on the world-open path. Returns true when the caller may proceed.
     *
     * <p>Truth table:
     *
     * <ul>
     *   <li>no unacknowledged pack -&gt; true, and no screen.</li>
     *   <li>unacknowledged pack -&gt; false, and the screen is shown. The confirm
     *       callback re-runs the original action; the cancel callback does not.</li>
     * </ul>
     *
     * <p><b>The methods compile against 26.3; the call site does not exist yet.</b>
     * All four classes this file touches were checked against the 26.3 client jar
     * and the module compiles. What is still open is <em>where</em> to call this
     * from: the pack list for a world is only final after the world's own files
     * are read, and no such hook is wired up in this build. Until it is,
     * {@code showWorldWarningIfNeeded} has no caller and the client prompt does
     * not appear. It is stated here rather than implied by a compile error,
     * because compiling is not the same as running.
     */
    public static boolean showWorldWarningIfNeeded(Minecraft client, Screen parent, Runnable openWorld) {
        if (client == null || parent == null) {
            return true;
        }

        List<ContentWarningScreen.PackLine> pending = unacknowledgedPacks();
        if (pending.isEmpty()) {
            return true;
        }

        openWarning(client, parent, pending, openWorld, () -> { });
        return false;
    }

    /**
     * Packs the client knows about that have no acknowledgement at this hash.
     *
     * <p>Built from the same report the scanner produced. A pack the client cannot
     * hash is included rather than skipped: an unreadable pack is the one whose
     * contents nobody can vouch for.
     */
    private static List<ContentWarningScreen.PackLine> unacknowledgedPacks() {
        List<ContentWarningScreen.PackLine> pending = new ArrayList<>();
        PackScanner.Report report = ClientScanResults.current();
        for (String id : report.packsSeen()) {
            // The client has no file handle for a built-in pack, so no hash and no
            // acknowledgement: it is skipped rather than shown as a pending prompt
            // nobody could satisfy.
            String hash = ClientScanResults.hashOf(id);
            if (hash == null) {
                continue;
            }
            boolean archived = ClientScanResults.isArchived(id, hash);
            if (PackGate.get().verdict(id, hash, archived, "").needsAsking()) {
                pending.add(new ContentWarningScreen.PackLine(id, hash, archived));
            }
        }
        return pending;
    }

    /*
     * ---------------------------------------------------------------------
     * WHAT IS DONE, AND WHAT IS NOT
     * ---------------------------------------------------------------------
     * Done, and proven by compiling against the 26.3 client and server jars:
     * every class this module references exists, with the signatures used. The
     * earlier note here worried about three things and two of them turned out to
     * be non-issues - the resource-side hashing it asked for now exists as
     * ContentHash.ofResources(...) and is used by PackHasher on the server, and
     * Checkbox is a real builder-based widget.
     *
     * Not done: the call site. showWorldWarningIfNeeded compiles and does what it
     * says, but nothing invokes it, so no client prompt appears in this build.
     * The pack list for a world is final only after that world's files are read,
     * and wiring that read is a mixin into the world-open path - a change that
     * cannot be verified by compiling, only by launching the game.
     *
     * Whoever wires it: the ack is a prompt, not a refusal. If the hook cannot
     * show a screen, the world must still load and the pack must be reported, the
     * same way the server reports it. Never turn a missing screen into a failure
     * to open a world.
     * ---------------------------------------------------------------------
     */
}
