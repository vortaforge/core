package com.vortaforge.homemanager;

// AI-assisted: written with Claude (Anthropic). See CREDITS.md at the repo root.

import com.mojang.brigadier.Command;
import com.mojang.brigadier.arguments.StringArgumentType;
import com.mojang.brigadier.exceptions.CommandSyntaxException;
import net.fabricmc.api.ModInitializer;
import net.fabricmc.fabric.api.command.v2.CommandRegistrationCallback;
import net.fabricmc.fabric.api.event.lifecycle.v1.ServerLifecycleEvents;
import net.fabricmc.loader.api.FabricLoader;
import net.minecraft.registry.RegistryKey;
import net.minecraft.registry.RegistryKeys;
import net.minecraft.server.MinecraftServer;
import net.minecraft.server.command.CommandManager;
import net.minecraft.server.command.ServerCommandSource;
import net.minecraft.server.network.ServerPlayerEntity;
import net.minecraft.server.world.ServerWorld;
import net.minecraft.text.Text;
import net.minecraft.util.Formatting;
import net.minecraft.util.Identifier;
import net.minecraft.util.WorldSavePath;
import org.slf4j.Logger;
import org.slf4j.LoggerFactory;

import java.io.IOException;
import java.nio.file.Path;

/**
 * Home Manager - Fabric mod for Minecraft 1.21.1 (dedicated server).
 *
 * <p>{@code /sethome [name]}, {@code /home [name]}, {@code /delhome <name>}, {@code /homes}. The rules
 * live in {@link HomeBook}; persistence in {@link HomeFile} ({@code <world>/homes.json}).
 */
public class HomeManagerMod implements ModInitializer {

    public static final String MOD_ID = "home-manager";
    public static final Logger LOGGER = LoggerFactory.getLogger(MOD_ID);

    private static final String DEFAULT_NAME = "home";

    private HomeSettings settings;
    private HomeBook book;
    private Path file;
    /** Set when homes.json existed but could not be read: saving is then disabled so it is never overwritten. */
    private boolean readOnly;

    @Override
    public void onInitialize() {
        settings = SettingsFile.loadOrCreate(FabricLoader.getInstance().getConfigDir().resolve("home-manager.json"), LOGGER);

        ServerLifecycleEvents.SERVER_STARTED.register(this::load);
        ServerLifecycleEvents.SERVER_STOPPING.register(server -> save());

        CommandRegistrationCallback.EVENT.register((dispatcher, registryAccess, environment) -> {
            dispatcher.register(CommandManager.literal("sethome")
                    .executes(ctx -> setHome(ctx.getSource(), DEFAULT_NAME))
                    .then(CommandManager.argument("name", StringArgumentType.word())
                            .executes(ctx -> setHome(ctx.getSource(), StringArgumentType.getString(ctx, "name")))));
            dispatcher.register(CommandManager.literal("home")
                    .executes(ctx -> goHome(ctx.getSource(), DEFAULT_NAME))
                    .then(CommandManager.argument("name", StringArgumentType.word())
                            .executes(ctx -> goHome(ctx.getSource(), StringArgumentType.getString(ctx, "name")))));
            dispatcher.register(CommandManager.literal("delhome")
                    .then(CommandManager.argument("name", StringArgumentType.word())
                            .executes(ctx -> delHome(ctx.getSource(), StringArgumentType.getString(ctx, "name")))));
            dispatcher.register(CommandManager.literal("homes").executes(ctx -> listHomes(ctx.getSource())));
        });

        LOGGER.info("Home Manager active: up to {} homes per player.", settings.maxHomes);
    }

    private void load(MinecraftServer server) {
        file = server.getSavePath(WorldSavePath.ROOT).resolve("homes.json");
        try {
            book = HomeBook.restore(settings.maxHomes, HomeFile.load(file));
        } catch (IOException e) {
            LOGGER.error("Could not read {} ({}). Homes work for this session but are NOT saved, so the file is left untouched.",
                    file, e.getMessage());
            book = new HomeBook(settings.maxHomes);
            readOnly = true;
        }
    }

    private void save() {
        if (book != null && file != null && !readOnly) HomeFile.save(file, book.snapshot(), LOGGER);
    }

    private int setHome(ServerCommandSource source, String name) throws CommandSyntaxException {
        if (!ready(source)) return 0;
        ServerPlayerEntity player = source.getPlayerOrThrow();
        Home here = new Home(player.getWorld().getRegistryKey().getValue().toString(),
                player.getX(), player.getY(), player.getZ(), player.getYaw(), player.getPitch());
        switch (book.set(player.getUuidAsString(), name, here)) {
            case BAD_NAME -> {
                reply(source, "Home names are 1-" + HomeBook.MAX_NAME_LENGTH + " characters: letters, digits, _ and -.", Formatting.RED);
                return 0;
            }
            case LIMIT -> {
                reply(source, "You already have " + book.limit() + " homes. Use /delhome <name> to free a slot, or reuse a name to move it.", Formatting.RED);
                return 0;
            }
            case CREATED -> reply(source, "Home '" + HomeBook.normalizeName(name) + "' set.", Formatting.GREEN);
            case REPLACED -> reply(source, "Home '" + HomeBook.normalizeName(name) + "' moved here.", Formatting.GREEN);
        }
        save();
        return Command.SINGLE_SUCCESS;
    }

    private int goHome(ServerCommandSource source, String name) throws CommandSyntaxException {
        if (!ready(source)) return 0;
        ServerPlayerEntity player = source.getPlayerOrThrow();
        Home home = book.get(player.getUuidAsString(), name);
        if (home == null) {
            reply(source, "No home named '" + name + "'. See /homes.", Formatting.RED);
            return 0;
        }
        Identifier id = Identifier.tryParse(home.dimension());
        ServerWorld world = id == null ? null : source.getServer().getWorld(RegistryKey.of(RegistryKeys.WORLD, id));
        if (world == null) {
            reply(source, "That home is in a dimension that no longer exists (" + home.dimension() + ").", Formatting.RED);
            return 0;
        }
        player.teleport(world, home.x(), home.y(), home.z(), home.yaw(), home.pitch());
        reply(source, "Teleported to home '" + HomeBook.normalizeName(name) + "'.", Formatting.GREEN);
        return Command.SINGLE_SUCCESS;
    }

    private int delHome(ServerCommandSource source, String name) throws CommandSyntaxException {
        if (!ready(source)) return 0;
        ServerPlayerEntity player = source.getPlayerOrThrow();
        if (!book.delete(player.getUuidAsString(), name)) {
            reply(source, "No home named '" + name + "'.", Formatting.RED);
            return 0;
        }
        save();
        reply(source, "Home '" + HomeBook.normalizeName(name) + "' deleted.", Formatting.YELLOW);
        return Command.SINGLE_SUCCESS;
    }

    private int listHomes(ServerCommandSource source) throws CommandSyntaxException {
        if (!ready(source)) return 0;
        ServerPlayerEntity player = source.getPlayerOrThrow();
        var names = book.names(player.getUuidAsString());
        reply(source, names.isEmpty()
                ? "You have no homes. Use /sethome [name]."
                : "Homes (" + names.size() + "/" + book.limit() + "): " + String.join(", ", names), Formatting.YELLOW);
        return Command.SINGLE_SUCCESS;
    }

    private boolean ready(ServerCommandSource source) {
        if (book != null) return true;
        reply(source, "Homes are not loaded yet, try again in a moment.", Formatting.RED);
        return false;
    }

    private static void reply(ServerCommandSource source, String message, Formatting color) {
        source.sendFeedback(() -> Text.literal(message).formatted(color), false);
    }
}
