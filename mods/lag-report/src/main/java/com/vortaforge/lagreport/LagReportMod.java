package com.vortaforge.lagreport;

// AI-assisted: written with Claude (Anthropic). See CREDITS.md at the repo root.

import com.mojang.brigadier.Command;
import net.fabricmc.api.ModInitializer;
import net.fabricmc.fabric.api.command.v2.CommandRegistrationCallback;
import net.fabricmc.loader.api.FabricLoader;
import net.minecraft.entity.Entity;
import net.minecraft.registry.Registries;
import net.minecraft.server.MinecraftServer;
import net.minecraft.server.command.CommandManager;
import net.minecraft.server.command.ServerCommandSource;
import net.minecraft.server.world.ServerWorld;
import net.minecraft.text.Text;
import net.minecraft.util.Formatting;
import org.slf4j.Logger;
import org.slf4j.LoggerFactory;

/**
 * Lag Report - Fabric mod for Minecraft 1.21.1 (dedicated server).
 *
 * <p>{@code /lag} reads the server's average tick time and walks the loaded entities of every
 * dimension once. It changes nothing. The walk runs on the server thread, so on a very large world
 * the command itself takes a moment; that is why it is operator-only by default.
 */
public class LagReportMod implements ModInitializer {

    public static final String MOD_ID = "lag-report";
    public static final Logger LOGGER = LoggerFactory.getLogger(MOD_ID);

    private LagReportSettings settings;

    @Override
    public void onInitialize() {
        settings = SettingsFile.loadOrCreate(FabricLoader.getInstance().getConfigDir().resolve("lag-report.json"), LOGGER);

        CommandRegistrationCallback.EVENT.register((dispatcher, registryAccess, environment) ->
                dispatcher.register(CommandManager.literal("lag")
                        .requires(source -> source.hasPermissionLevel(settings.permissionLevel))
                        .executes(ctx -> report(ctx.getSource()))));

        LOGGER.info("Lag Report active: /lag needs permission level {}, lists top {} entity types.",
                settings.permissionLevel, settings.topEntityTypes);
    }

    private int report(ServerCommandSource source) {
        MinecraftServer server = source.getServer();
        double mspt = server.getAverageTickTime();
        send(source, String.format("Tick: %.1f ms avg, %.1f TPS (%s)", mspt, Tps.fromMspt(mspt), Tps.status(mspt)), Formatting.YELLOW);

        for (ServerWorld world : server.getWorlds()) {
            EntityCensus census = new EntityCensus();
            for (Entity entity : world.iterateEntities()) {
                census.add(Registries.ENTITY_TYPE.getId(entity.getType()).toString());
            }
            String dimension = world.getRegistryKey().getValue().toString();
            send(source, dimension + ": " + census.total() + " entities, " + world.getPlayers().size() + " players", Formatting.GRAY);
            for (EntityCensus.Count c : census.top(settings.topEntityTypes)) {
                send(source, "  " + c.count() + " x " + c.type(), Formatting.DARK_GRAY);
            }
        }
        return Command.SINGLE_SUCCESS;
    }

    private static void send(ServerCommandSource source, String line, Formatting color) {
        source.sendFeedback(() -> Text.literal(line).formatted(color), false);
    }
}
