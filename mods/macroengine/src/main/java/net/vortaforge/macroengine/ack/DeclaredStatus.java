package net.vortaforge.macroengine.ack;

import com.google.gson.JsonElement;
import com.google.gson.JsonObject;
import com.google.gson.JsonParser;

/**
 * Reads a pack's own retirement declaration out of {@code pack.mcmeta}.
 *
 * <h2>The shape</h2>
 *
 * <pre>
 * {
 *   "pack": { "description": "...", "min_format": [121, 0], "max_format": [121, 0] },
 *   "vortaforge": { "status": "archived" }
 * }
 * </pre>
 *
 * <p>The block sits at the root, next to {@code pack}, not inside it: a pack
 * format's own schema does not know about it, so putting it there keeps vanilla's
 * parser from having an opinion about a key it does not own. Vanilla ignores
 * unknown root keys; that is why this can exist at all.
 *
 * <h2>What it is not</h2>
 *
 * It is not a claim of safety, and it is not trusted for anything except making a
 * warning stronger. A pack that says it is archived gets the harsher text; a pack
 * that says it is fine gets the general text. Neither answer is used to permit or
 * refuse a load, because the decision belongs to the person reading the warning.
 *
 * <h2>Why parsing is this defensive</h2>
 *
 * The input is a file from a pack we are already suspicious of. Every accessor
 * returns a default rather than throwing, and a malformed document reads as "no
 * declaration" - the conservative answer, since the general warning is the one
 * that assumes less.
 */
public final class DeclaredStatus {
    private DeclaredStatus() {
    }

    /** True when the document declares {@code "vortaforge": {"status": "archived"}}. */
    public static boolean declaresArchived(String packMetaJson) {
        return "archived".equalsIgnoreCase(status(packMetaJson));
    }

    /** The declared status, or null when there is none or it is unreadable. */
    public static String status(String packMetaJson) {
        if (packMetaJson == null || packMetaJson.isBlank()) {
            return null;
        }
        try {
            JsonElement root = JsonParser.parseString(packMetaJson);
            if (!root.isJsonObject()) {
                return null;
            }
            JsonObject obj = root.getAsJsonObject();
            JsonElement block = obj.get("vortaforge");
            if (block == null || !block.isJsonObject()) {
                return null;
            }
            JsonElement status = block.getAsJsonObject().get("status");
            if (status == null || !status.isJsonPrimitive() || !status.getAsJsonPrimitive().isString()) {
                return null;
            }
            String value = status.getAsString().trim();
            return value.isEmpty() ? null : value;
        } catch (RuntimeException e) {
            // Malformed JSON, a number where a string was expected, a null in an
            // unexpected place - all of them mean "says nothing".
            return null;
        }
    }
}
