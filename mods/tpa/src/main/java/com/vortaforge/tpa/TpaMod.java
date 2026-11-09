package com.vortaforge.tpa;

// AI-assisted: written with Claude (Anthropic). See CREDITS.md at the repo root.

import com.mojang.brigadier.Command;
import net.fabricmc.api.ModInitializer;
import net.fabricmc.fabric.api.command.v2.CommandRegistrationCallback;
import net.fabricmc.fabric.api.networking.v1.ServerPlayConnectionEvents;
import net.fabricmc.loader.api.FabricLoader;
import net.minecraft.command.argument.EntityArgumentType;
import net.minecraft.server.MinecraftServer;
import net.minecraft.server.command.CommandManager;
import net.minecraft.server.command.ServerCommandSource;
import net.minecraft.server.network.ServerPlayerEntity;
import net.minecraft.text.Text;
import net.minecraft.util.Formatting;
import org.slf4j.Logger;
import org.slf4j.LoggerFactory;

import java.util.UUID;

/**
 * TPA - Fabric mod for Minecraft 1.21.1 (dedicated server).
 *
 * <p>{@code /tpa <player>} asks to teleport <em>to</em> that player; they answer with
 * {@code /tpaccept} or {@code /tpdeny}. The request rules live in {@link RequestBook}.
 */
public class TpaMod implements ModInitializer {

    public static final String MOD_ID = "tpa";
    public static final Logger LOGGER = LoggerFactory.getLogger(MOD_ID);

    private static final int MAX_COOLDOWN_ENTRIES = 4096;

    private TpaSettings settings;
    private RequestBook<UUID> book;

    @Override
    public void onInitialize() {
        settings = SettingsFile.loadOrCreate(FabricLoader.getInstance().getConfigDir().resolve("tpa.json"), LOGGER);
        book = new RequestBook<>(settings.expirySeconds * 1000L, settings.cooldownSeconds * 1000L, MAX_COOLDOWN_ENTRIES);

        ServerPlayConnectionEvents.DISCONNECT.register((handler, server) -> book.forget(handler.player.getUuid()));

        CommandRegistrationCallback.EVENT.register((dispatcher, registryAccess, environment) -> {
            dispatcher.register(CommandManager.literal("tpa")
                    .then(CommandManager.argument("player", EntityArgumentType.player())
                            .executes(ctx -> request(ctx.getSource(), EntityArgumentType.getPlayer(ctx, "player")))));
            dispatcher.register(CommandManager.literal("tpaccept").executes(ctx -> accept(ctx.getSource())));
            dispatcher.register(CommandManager.literal("tpdeny").executes(ctx -> deny(ctx.getSource())));
            dispatcher.register(CommandManager.literal("tpcancel").executes(ctx -> cancel(ctx.getSource())));
        });

        LOGGER.info("TPA active: requests expire after {}s, cooldown {}s, cross-dimension {}.",
                settings.expirySeconds, settings.cooldownSeconds, settings.allowCrossDimension ? "allowed" : "blocked");
    }

    private static long now(MinecraftServer server) {
        return server.getTicks() * 50L;
    }

    private int request(ServerCommandSource source, ServerPlayerEntity target) throws com.mojang.brigadier.exceptions.CommandSyntaxException {
        ServerPlayerEntity sender = source.getPlayerOrThrow();
        RequestBook.Result result = book.request(sender.getUuid(), target.getUuid(), now(source.getServer()));
        switch (result.verdict()) {
            case SELF -> {
                reply(source, "You cannot send a teleport request to yourself.", Formatting.RED);
                return 0;
            }
            case COOLDOWN -> {
                reply(source, "Please wait " + ((result.retryAfterMillis() + 999) / 1000) + "s before sending another request.", Formatting.RED);
                return 0;
            }
            case OK -> { }
        }
        reply(source, "Teleport request sent to " + target.getGameProfile().getName() + ". It expires in " + settings.expirySeconds + "s.", Formatting.YELLOW);
        target.sendMessage(Text.literal(sender.getGameProfile().getName() + " wants to teleport to you. /tpaccept or /tpdeny.")
                .formatted(Formatting.YELLOW), false);
        return Command.SINGLE_SUCCESS;
    }

    private int accept(ServerCommandSource source) throws com.mojang.brigadier.exceptions.CommandSyntaxException {
        ServerPlayerEntity target = source.getPlayerOrThrow();
        MinecraftServer server = source.getServer();
        UUID requesterId = book.take(target.getUuid(), now(server));
        if (requesterId == null) {
            reply(source, "You have no pending teleport request.", Formatting.RED);
            return 0;
        }
        ServerPlayerEntity requester = server.getPlayerManager().getPlayer(requesterId);
        if (requester == null) {
            reply(source, "That player is no longer online.", Formatting.RED);
            return 0;
        }
        if (!settings.allowCrossDimension && requester.getWorld() != target.getWorld()) {
            reply(source, "Cross-dimension teleports are disabled on this server.", Formatting.RED);
            requester.sendMessage(Text.literal("Your teleport was refused: cross-dimension teleports are disabled.").formatted(Formatting.RED), false);
            return 0;
        }
        requester.teleport(target.getServerWorld(), target.getX(), target.getY(), target.getZ(), target.getYaw(), target.getPitch());
        reply(source, "Teleport request accepted.", Formatting.GREEN);
        requester.sendMessage(Text.literal(target.getGameProfile().getName() + " accepted your teleport request.").formatted(Formatting.GREEN), false);
        return Command.SINGLE_SUCCESS;
    }

    private int deny(ServerCommandSource source) throws com.mojang.brigadier.exceptions.CommandSyntaxException {
        ServerPlayerEntity target = source.getPlayerOrThrow();
        MinecraftServer server = source.getServer();
        UUID requesterId = book.take(target.getUuid(), now(server));
        if (requesterId == null) {
            reply(source, "You have no pending teleport request.", Formatting.RED);
            return 0;
        }
        reply(source, "Teleport request denied.", Formatting.YELLOW);
        ServerPlayerEntity requester = server.getPlayerManager().getPlayer(requesterId);
        if (requester != null) {
            requester.sendMessage(Text.literal(target.getGameProfile().getName() + " denied your teleport request.").formatted(Formatting.RED), false);
        }
        return Command.SINGLE_SUCCESS;
    }

    private int cancel(ServerCommandSource source) throws com.mojang.brigadier.exceptions.CommandSyntaxException {
        ServerPlayerEntity sender = source.getPlayerOrThrow();
        if (!book.cancel(sender.getUuid(), now(source.getServer()))) {
            reply(source, "You have no pending teleport request.", Formatting.RED);
            return 0;
        }
        reply(source, "Teleport request cancelled.", Formatting.YELLOW);
        return Command.SINGLE_SUCCESS;
    }

    private static void reply(ServerCommandSource source, String message, Formatting color) {
        source.sendFeedback(() -> Text.literal(message).formatted(color), false);
    }
}
