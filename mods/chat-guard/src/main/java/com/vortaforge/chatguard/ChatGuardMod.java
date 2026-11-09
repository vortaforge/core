package com.vortaforge.chatguard;

// AI-assisted: written with Claude (Anthropic). See CREDITS.md at the repo root.

import net.fabricmc.api.ModInitializer;
import net.fabricmc.fabric.api.message.v1.ServerMessageEvents;
import net.fabricmc.fabric.api.networking.v1.ServerPlayConnectionEvents;
import net.fabricmc.loader.api.FabricLoader;
import net.minecraft.server.MinecraftServer;
import net.minecraft.server.network.ServerPlayerEntity;
import net.minecraft.text.Text;
import net.minecraft.util.Formatting;
import org.slf4j.Logger;
import org.slf4j.LoggerFactory;

import java.util.UUID;

/**
 * Chat Guard - Fabric mod for Minecraft 1.21.1 (dedicated server).
 *
 * <p>Hooks {@code ALLOW_CHAT_MESSAGE}, so a rejected message is never broadcast. The decision itself
 * lives in {@link ChatLimiter}. Only public chat is covered, not {@code /msg}, {@code /me} or {@code /say}.
 */
public class ChatGuardMod implements ModInitializer {

    public static final String MOD_ID = "chat-guard";
    public static final Logger LOGGER = LoggerFactory.getLogger(MOD_ID);

    private static final int MAX_TRACKED_SENDERS = 4096;

    private ChatGuardSettings settings;
    private ChatLimiter<UUID> limiter;

    @Override
    public void onInitialize() {
        settings = SettingsFile.loadOrCreate(FabricLoader.getInstance().getConfigDir().resolve("chat-guard.json"), LOGGER);
        limiter = new ChatLimiter<>(settings.maxMessages, settings.windowSeconds * 1000L,
                settings.duplicateSeconds * 1000L, settings.maxLength, MAX_TRACKED_SENDERS);

        ServerMessageEvents.ALLOW_CHAT_MESSAGE.register((message, sender, params) -> allow(sender, message.getSignedContent()));
        ServerPlayConnectionEvents.DISCONNECT.register((handler, server) -> limiter.remove(handler.player.getUuid()));

        LOGGER.info("Chat Guard active: max {} messages / {}s, duplicates {}, max length {}.",
                settings.maxMessages, settings.windowSeconds,
                settings.duplicateSeconds == 0 ? "allowed" : "blocked for " + settings.duplicateSeconds + "s",
                settings.maxLength);
    }

    private boolean allow(ServerPlayerEntity sender, String content) {
        MinecraftServer server = sender.getServer();
        if (server == null) return true;
        if (settings.exemptOperators && server.getPlayerManager().isOperator(sender.getGameProfile())) return true;

        // Ticks, not wall-clock time: a stalled server must not count the stall as the sender being quiet.
        ChatLimiter.Verdict verdict = limiter.check(sender.getUuid(), content, server.getTicks() * 50L);
        String reason = switch (verdict) {
            case ALLOW -> null;
            case TOO_FAST -> settings.tooFastMessage;
            case DUPLICATE -> settings.duplicateMessage;
            case TOO_LONG -> settings.tooLongMessage;
        };
        if (reason == null) return true;
        sender.sendMessage(Text.literal(reason).formatted(Formatting.RED), false);
        return false;
    }
}
