package com.vortaforge.deathpoint;

// AI-assisted: written with Claude (Anthropic). See CREDITS.md at the repo root.

import com.mojang.brigadier.Command;
import net.fabricmc.api.ModInitializer;
import net.fabricmc.fabric.api.command.v2.CommandRegistrationCallback;
import net.fabricmc.fabric.api.entity.event.v1.ServerLivingEntityEvents;
import net.fabricmc.loader.api.FabricLoader;
import net.minecraft.server.command.CommandManager;
import net.minecraft.server.network.ServerPlayerEntity;
import net.minecraft.text.Text;
import net.minecraft.util.Formatting;
import net.minecraft.util.math.BlockPos;
import org.slf4j.Logger;
import org.slf4j.LoggerFactory;

import java.util.UUID;

/**
 * Death Point - Fabric mod for Minecraft 1.21.1 (dedicated server).
 *
 * <p>Remembers where each player last died (memory only) and tells them. The bookkeeping is
 * {@link DeathBook} / {@link DeathRecord}.
 */
public class DeathPointMod implements ModInitializer {

    public static final String MOD_ID = "death-point";
    public static final Logger LOGGER = LoggerFactory.getLogger(MOD_ID);

    private static final int MAX_TRACKED_PLAYERS = 4096;

    private final DeathBook<UUID> book = new DeathBook<>(MAX_TRACKED_PLAYERS);
    private DeathPointSettings settings;

    @Override
    public void onInitialize() {
        settings = SettingsFile.loadOrCreate(FabricLoader.getInstance().getConfigDir().resolve("death-point.json"), LOGGER);

        ServerLivingEntityEvents.AFTER_DEATH.register((entity, damageSource) -> {
            if (entity instanceof ServerPlayerEntity player) onPlayerDeath(player);
        });

        if (settings.enableCommand) {
            CommandRegistrationCallback.EVENT.register((dispatcher, registryAccess, environment) ->
                    dispatcher.register(CommandManager.literal("deathpos").executes(ctx -> {
                        ServerPlayerEntity player = ctx.getSource().getPlayerOrThrow();
                        DeathRecord last = book.last(player.getUuid());
                        Text reply = last == null
                                ? Text.literal("No death recorded since the server started.").formatted(Formatting.GRAY)
                                : Text.literal("You last died at " + last.describe() + ".").formatted(Formatting.YELLOW);
                        ctx.getSource().sendFeedback(() -> reply, false);
                        return Command.SINGLE_SUCCESS;
                    })));
        }

        LOGGER.info("Death Point active: announce={}, /deathpos={}.", settings.announce, settings.enableCommand);
    }

    private void onPlayerDeath(ServerPlayerEntity player) {
        BlockPos pos = player.getBlockPos();
        DeathRecord record = new DeathRecord(player.getWorld().getRegistryKey().getValue().toString(),
                pos.getX(), pos.getY(), pos.getZ());
        book.record(player.getUuid(), record);
        if (settings.announce) {
            player.sendMessage(Text.literal("You died at " + record.describe() + ".").formatted(Formatting.YELLOW), false);
        }
    }
}
