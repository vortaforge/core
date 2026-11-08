package net.vortaforge.macroengine.client;

import net.minecraft.client.gui.GuiGraphicsExtractor;
import net.minecraft.client.gui.components.Button;
import net.minecraft.client.gui.components.Checkbox;
import net.minecraft.client.gui.screens.Screen;
import net.minecraft.network.chat.Component;
import net.vortaforge.macroengine.ack.PackGate;

import java.util.ArrayList;
import java.util.List;

/**
 * The acknowledgement screen: what is loaded, what was found, and a decision.
 *
 * <h2>Why a screen rather than a chat line</h2>
 *
 * A datapack's warning in chat scrolls away, and on a fresh world there is no chat
 * history to scroll. This sits in front of the decision instead of after it.
 *
 * <h2>What changed from the previous version</h2>
 *
 * It used to have two buttons that both continued: "Continue" returned to the
 * parent screen and "Back" did the same thing by a different route. Neither
 * recorded anything, so the screen was a notification wearing the clothes of a
 * consent dialogue. Three things are different now:
 *
 * <ul>
 *   <li><b>"I accept the risk" is disabled until the checkbox is ticked.</b> A
 *       button you can press without reading is a button that gets pressed.</li>
 *   <li><b>"Cancel" actually cancels.</b> {@link #onClose()} reports failure to its
 *       caller, and the caller does not open the world. {@code isPauseScreen()}
 *       returning false no longer implies "nothing can go wrong".</li>
 *   <li><b>Accepting writes a record</b>, bound to each listed pack's content hash,
 *       so the screen does not appear again for the same bytes and does appear
 *       again for different ones.</li>
 * </ul>
 *
 * <h2>Confirmed vs unverified for 26.3</h2>
 *
 * Confirmed by the previous implementation of this same file: {@link Screen},
 * {@code init()}, {@code addRenderableWidget}, {@link Button#builder},
 * {@link GuiGraphicsExtractor}, {@code centeredText}, {@code text}, {@code font},
 * {@code setScreenAndShow}.
 *
 * <p><b>Unverified:</b> {@link Checkbox} - its constructor signature and whether it
 * is a {@code Renderable} that {@code addRenderableWidget} accepts. If the class or
 * its constructor does not exist, this file will not compile, which is the correct
 * failure. The alternative is a plain button that toggles a boolean, at the cost of
 * looking less like a consent control than it is.
 */
public final class ContentWarningScreen extends Screen {
    private static final int MARGIN = 24;
    private static final int MAX_LINES = 9;

    private final Screen parent;
    private final List<PackLine> packs;
    private final List<String> lines;
    private final Runnable onCancel;
    private final boolean highSeverity;

    /** One pack waiting for a decision. */
    public record PackLine(String id, String hash, boolean archived) {
    }

    private final Runnable onConfirm;
    private boolean accepted;
    private Button acceptButton;

    /**
     * @param onConfirm run after the record is written; the caller proceeds
     * @param onCancel  run when the player backs out; the caller must not proceed
     */
    public ContentWarningScreen(Screen parent,
                                List<PackLine> packs,
                                List<String> findings,
                                boolean highSeverity,
                                Runnable onConfirm,
                                Runnable onCancel) {
        super(Component.literal("macroEngine - confirm data packs"));
        this.parent = parent;
        this.packs = List.copyOf(packs);
        this.highSeverity = highSeverity;
        this.onCancel = onCancel;
        this.lines = buildLines(packs, findings);
        this.onConfirm = onConfirm;
    }

    private static List<String> buildLines(List<PackLine> packs, List<String> findings) {
        List<String> out = new ArrayList<>();
        for (PackLine pack : packs) {
            out.add((pack.archived() ? "[ARCHIVED] " : "") + pack.id());
        }
        if (!findings.isEmpty()) {
            out.add("");
            int shown = 0;
            for (String finding : findings) {
                if (shown++ >= MAX_LINES) {
                    out.add("… and " + (findings.size() - MAX_LINES) + " more. See the server log.");
                    break;
                }
                out.add(finding);
            }
        }
        return out;
    }

    @Override
    protected void init() {
        int buttonY = this.height - 44;

        acceptButton = Button.builder(
                        Component.literal("I accept the risk"),
                        b -> accept())
                .bounds(this.width / 2 - 155, buttonY, 150, 20)
                .build();
        acceptButton.active = false;
        this.addRenderableWidget(acceptButton);

        this.addRenderableWidget(Button.builder(
                        Component.literal("Cancel"),
                        b -> cancel())
                .bounds(this.width / 2 + 5, buttonY, 150, 20)
                .build());

        this.addRenderableWidget(Checkbox.builder(
                        Component.literal("I have read what these packs do"),
                        this.font)
                .pos(this.width / 2 - 155, buttonY - 26)
                .selected(false)
                .onValueChange((box, value) -> acceptButton.active = value)
                .build());
    }

    private void accept() {
        if (!accepted) {
            accepted = true;
            // The name is cosmetic - it says who wrote the record, and the record
            // is per-machine anyway. Deliberately not reaching for a profile API
            // here: the accessor name was not verified for 26.3, and a failure to
            // describe the approver must not stop the approval from being saved.
            String by = "client";
            for (PackLine pack : packs) {
                PackGate.get().acknowledge(pack.id(), pack.hash(), by);
            }
        }
        if (onConfirm != null) {
            onConfirm.run();
        }
        if (this.minecraft != null) {
            this.minecraft.setScreenAndShow(parent);
        }
    }

    private void cancel() {
        if (onCancel != null) {
            onCancel.run();
        }
        if (this.minecraft != null) {
            this.minecraft.setScreenAndShow(parent);
        }
    }

    /**
     * Escape and the window close button both land here.
     *
     * <p>Treated as Cancel, not as Accept: a decision made by pressing Escape is
     * not a decision, and it must not leave a record behind.
     */
    @Override
    public void onClose() {
        cancel();
    }

    @Override
    public void extractRenderState(GuiGraphicsExtractor graphics, int mouseX, int mouseY, float partialTick) {
        super.extractRenderState(graphics, mouseX, mouseY, partialTick);

        int top = 30;
        graphics.centeredText(this.font,
                highSeverity ? "macroEngine: unacknowledged packs with findings"
                        : "macroEngine: packs you have not confirmed",
                this.width / 2, top, highSeverity ? 0xFFFF5555 : 0xFFFFCC66);
        top += 20;

        graphics.centeredText(this.font,
                "These data packs will load in this world and can run commands.",
                this.width / 2, top, 0xFFAAAAAA);
        top += 14;
        graphics.centeredText(this.font,
                "A retired pack gets no fixes. The risk is yours to accept.",
                this.width / 2, top, 0xFFAAAAAA);
        top += 22;

        for (String line : lines) {
            String shown = line;
            int maxWidth = this.width - MARGIN * 2;
            if (this.font.width(shown) > maxWidth) {
                while (shown.length() > 4 && this.font.width(shown + "…") > maxWidth) {
                    shown = shown.substring(0, shown.length() - 1);
                }
                shown = shown + "…";
            }
            int colour = line.startsWith("[ARCHIVED]") ? 0xFFFF5555
                    : line.startsWith("[HIGH]") ? 0xFFFF8888
                    : 0xFFDDDDDD;
            graphics.text(this.font, shown, MARGIN, top, colour, false);
            top += 13;
        }
    }

    @Override
    public boolean isPauseScreen() {
        // The world is not running yet; pausing is meaningless here.
        return false;
    }

    @Override
    public boolean shouldCloseOnEsc() {
        // Escape must go through onClose so the cancel path runs.
        return true;
    }
}
