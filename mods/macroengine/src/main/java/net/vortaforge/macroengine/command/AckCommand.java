package net.vortaforge.macroengine.command;

import com.mojang.brigadier.arguments.StringArgumentType;
import net.minecraft.commands.Commands;
import net.minecraft.commands.SharedSuggestionProvider;
import net.minecraft.network.chat.Component;
import net.minecraft.server.packs.repository.PackRepository;
import net.minecraft.server.packs.repository.Pack;
import net.vortaforge.macroengine.ack.PackGate;

import java.util.ArrayList;
import java.util.List;

/**
 * {@code /macroengine ack ...} - the operator's half of the acknowledgement flow.
 *
 * <h2>Why permission level 4</h2>
 *
 * Acknowledging a pack is the act of saying "I have seen what this does and I
 * accept it". On a dedicated server that decision belongs to whoever owns the
 * server, not to a gamemaster who happens to be online, so this sits one level
 * above the rest of {@code /macroengine}.
 *
 * <h2>Three forms</h2>
 *
 * <ul>
 *   <li>{@code /macroengine ack list} - every pack that is not acknowledged at its
 *       current hash, with the reason it needs asking.</li>
 *   <li>{@code /macroengine ack <pack>} - acknowledge one, at its current hash.</li>
 *   <li>{@code /macroengine ack reload} - re-read the record from disk, for when a
 *       second server process wrote it.</li>
 * </ul>
 *
 * <h2>Verified, not guessed</h2>
 *
 * The pack id is resolved through {@link PackRepository#getPack}, which is the
 * game's own id-to-pack lookup. If that method name is wrong for 26.3 this class
 * will not compile - which is the correct failure - rather than silently reading a
 * folder that is not what the game loaded.
 */
public final class AckCommand {
    private AckCommand() {
    }

    /** Registers on the same callback as {@link MacroCommand}; called once from onInitialize. */
    public static void register() {
        net.fabricmc.fabric.api.command.v2.CommandRegistrationCallback.EVENT.register(
                (dispatcher, registryAccess, environment) -> registerInto(dispatcher));
    }

    private static void registerInto(com.mojang.brigadier.CommandDispatcher<net.minecraft.commands.CommandSourceStack> dispatcher) {
        dispatcher.register(Commands.literal("macroengine")
                .requires(Commands.hasPermission(Commands.LEVEL_ADMINS))
                .then(Commands.literal("ack")
                        .then(Commands.literal("list")
                                .executes(ctx -> list(ctx.getSource())))
                        .then(Commands.literal("reload")
                                .executes(ctx -> {
                                    PackGate.reload();
                                    ctx.getSource().sendSuccess(
                                            () -> Component.literal("macroEngine: acknowledgement record re-read"), false);
                                    return 1;
                                }))
                        .then(Commands.argument("pack", StringArgumentType.word())
                                .suggests((ctx, builder) -> SharedSuggestionProvider.suggest(
                                        unacknowledgedIds(ctx.getSource().getServer().getPackRepository()), builder))
                                .executes(ctx -> acknowledge(ctx.getSource(),
                                        StringArgumentType.getString(ctx, "pack"))))));
    }

    private static List<String> unacknowledgedIds(PackRepository repository) {
        List<String> ids = new ArrayList<>();
        for (Pack pack : repository.getAvailablePacks()) {
            String hash = PackHasher.hashOf(pack);
            if (hash == null) {
                continue;
            }
            boolean archived = ArchiveLookup.isArchived(pack.getId(), hash, pack);
            if (PackGate.get().verdict(pack.getId(), hash, archived, "").needsAsking()) {
                ids.add(pack.getId());
            }
        }
        return ids;
    }

    private static int list(net.minecraft.commands.CommandSourceStack source) {
        PackRepository repository = source.getServer().getPackRepository();
        int pending = 0;
        for (Pack pack : repository.getAvailablePacks()) {
            String hash = PackHasher.hashOf(pack);
            boolean archived = hash != null && ArchiveLookup.isArchived(pack.getId(), hash, pack);

            var verdict = PackGate.get().verdict(pack.getId(), hash, archived, "");
            if (!verdict.needsAsking()) {
                continue;
            }
            pending++;
            String line = (archived ? "[archived] " : "") + pack.getId()
                    + " (" + (hash == null ? "no hash" : hash.substring(0, 12)) + "): "
                    + verdict.reason();
            source.sendSuccess(() -> Component.literal("  " + line), false);
        }
        if (pending == 0) {
            source.sendSuccess(() -> Component.literal(
                    "macroEngine: every loaded pack is acknowledged at its current content hash"), false);
            return 1;
        }
        int total = pending;
        source.sendSuccess(() -> Component.literal(
                "macroEngine: " + total + " pack(s) not acknowledged. Acknowledge with "
                        + "/macroengine ack <pack>, after reading what the pack does."), false);
        return 0;
    }

    private static int acknowledge(net.minecraft.commands.CommandSourceStack source, String id) {
        Pack pack = source.getServer().getPackRepository().getPack(id);
        if (pack == null) {
            source.sendFailure(Component.literal("macroEngine: no pack named '" + id
                    + "'. Try /macroengine ack list."));
            return 0;
        }

        String hash = PackHasher.hashOf(pack);
        if (hash == null) {
            source.sendFailure(Component.literal("macroEngine: '" + id
                    + "' could not be hashed. An unreadable pack cannot be acknowledged."));
            return 0;
        }

        String by = source.getTextName();
        if (!PackGate.get().acknowledge(id, hash, by)) {
            source.sendFailure(Component.literal("macroEngine: acknowledgement could not be saved to "
                    + PackGate.get().recordPath() + " - see the log"));
            return 0;
        }

        boolean archived = ArchiveLookup.isArchived(id, hash, pack);
        String warning = archived
                ? " This pack is RETIRED and unmaintained; the risk is yours."
                : "";
        source.sendSuccess(() -> Component.literal("macroEngine: acknowledged '" + id + "' at "
                + hash.substring(0, 12) + "." + warning), false);
        return 1;
    }

}
