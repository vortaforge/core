package com.vortaforge.homemanager;

// AI-assisted: written with Claude (Anthropic). See CREDITS.md at the repo root.

import com.google.gson.Gson;
import com.google.gson.GsonBuilder;
import com.google.gson.reflect.TypeToken;
import org.slf4j.Logger;

import java.io.IOException;
import java.nio.charset.StandardCharsets;
import java.nio.file.AtomicMoveNotSupportedException;
import java.nio.file.Files;
import java.nio.file.Path;
import java.nio.file.StandardCopyOption;
import java.util.LinkedHashMap;
import java.util.Map;

/** Reads and writes {@code homes.json} in the world folder. Kept apart from {@link HomeBook} so the latter stays Gson-free. */
final class HomeFile {

    private static final Gson GSON = new GsonBuilder().setPrettyPrinting().create();
    private static final java.lang.reflect.Type TYPE = new TypeToken<Map<String, Map<String, Home>>>() {}.getType();

    private HomeFile() {}

    /**
     * Returns the stored homes, or an empty map if the file does not exist.
     *
     * @throws IOException if the file exists but cannot be read or parsed. The caller must NOT overwrite
     *                     it in that case, or a single bad byte would wipe every player's homes.
     */
    static Map<String, Map<String, Home>> load(Path file) throws IOException {
        if (!Files.exists(file)) return new LinkedHashMap<>();
        try {
            Map<String, Map<String, Home>> parsed = GSON.fromJson(Files.readString(file, StandardCharsets.UTF_8), TYPE);
            return parsed == null ? new LinkedHashMap<>() : parsed;
        } catch (RuntimeException e) {
            throw new IOException("homes file is not valid JSON: " + e.getMessage(), e);
        }
    }

    /** Writes to a temporary file first, then moves it over the real one, so a crash cannot leave half a file. */
    static void save(Path file, Map<String, Map<String, Home>> homes, Logger log) {
        Path tmp = file.resolveSibling(file.getFileName() + ".tmp");
        try {
            Files.writeString(tmp, GSON.toJson(homes, TYPE), StandardCharsets.UTF_8);
            try {
                Files.move(tmp, file, StandardCopyOption.REPLACE_EXISTING, StandardCopyOption.ATOMIC_MOVE);
            } catch (AtomicMoveNotSupportedException e) {
                Files.move(tmp, file, StandardCopyOption.REPLACE_EXISTING);
            }
        } catch (IOException e) {
            log.error("Could not save {}: {}", file.getFileName(), e.getMessage());
        }
    }
}
