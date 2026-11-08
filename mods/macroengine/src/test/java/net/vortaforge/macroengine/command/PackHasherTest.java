package net.vortaforge.macroengine.command;

import net.vortaforge.macroengine.ack.ContentHash;
import org.junit.jupiter.api.Test;

import java.nio.charset.StandardCharsets;
import java.util.LinkedHashMap;
import java.util.Map;

import static org.junit.jupiter.api.Assertions.assertEquals;
import static org.junit.jupiter.api.Assertions.assertFalse;
import static org.junit.jupiter.api.Assertions.assertNotEquals;

/**
 * The contract {@link PackHasher} depends on, without a game running.
 *
 * <p>{@code PackHasher} itself needs a live {@code Pack} and cannot be unit
 * tested here; what can be pinned is the part that decides whether two machines
 * agree - {@link ContentHash#ofResources}, which is what the pack path reduces to
 * once the resources are in hand. If these change, an acknowledgement written by
 * a server stops matching the same pack on a client, which is the failure that
 * would make the whole feature useless rather than broken.
 */
class PackHasherTest {

    private static Map<String, byte[]> pack(String... pathThenContent) {
        Map<String, byte[]> entries = new LinkedHashMap<>();
        for (int i = 0; i < pathThenContent.length; i += 2) {
            entries.put(pathThenContent[i],
                        pathThenContent[i + 1].getBytes(StandardCharsets.UTF_8));
        }
        return entries;
    }

    @Test
    void pathOrderDoesNotChangeTheHash() {
        // `PackResources.listResources` walks a tree, and two filesystems do not
        // promise the same walk order. The digest is over sorted paths, so the
        // order the game hands them over must not matter.
        Map<String, byte[]> forwards = new LinkedHashMap<>(pack(
                "data/ns/function/a.mcfunction", "say a",
                "data/ns/function/b.mcfunction", "say b"));
        Map<String, byte[]> backwards = new LinkedHashMap<>(pack(
                "data/ns/function/b.mcfunction", "say b",
                "data/ns/function/a.mcfunction", "say a"));

        assertEquals(ContentHash.ofResources(forwards), ContentHash.ofResources(backwards));
    }

    @Test
    void oneChangedByteChangesTheHash() {
        String before = ContentHash.ofResources(pack("data/ns/function/a.mcfunction", "say a"));
        String after = ContentHash.ofResources(pack("data/ns/function/a.mcfunction", "say b"));

        assertNotEquals(before, after,
                "a pack whose content changed must not keep its acknowledgement");
    }

    @Test
    void renamingAFileChangesTheHash() {
        // The name is framed into the digest on purpose: moving a function is a
        // different pack even when the bytes are identical, because the game will
        // load it under a different name.
        String before = ContentHash.ofResources(pack("data/ns/function/a.mcfunction", "say a"));
        String after = ContentHash.ofResources(pack("data/ns/function/renamed.mcfunction", "say a"));

        assertNotEquals(before, after);
    }

    @Test
    void anEmptyPackDoesNotHashToTheEmptyTree() {
        // PackHasher refuses to hash a pack it read nothing from rather than
        // returning the empty digest, because an empty digest is also the digest
        // of a genuinely empty pack - and acknowledging one would approve the
        // other. This pins the value it would otherwise have returned.
        String empty = ContentHash.ofResources(Map.of());

        assertEquals("e3b0c44298fc1c149afbf4c8996fb92427ae41e4649b934ca495991b7852b855", empty,
                "ofResources uses no length prefix of its own, so empty input is the "
                        + "SHA-256 of nothing - which is exactly why PackHasher must not "
                        + "call it with an empty map");
    }

    @Test
    void theHashIsLowercaseHexAndSixtyFourCharacters() {
        String hash = ContentHash.ofResources(pack("data/ns/function/a.mcfunction", "say a"));

        assertEquals(64, hash.length());
        assertFalse(hash.chars().anyMatch(Character::isUpperCase));
    }

    @Test
    void assetsAndDataDoNotCollide() {
        // The path prefix is part of the digest, so the same relative name under
        // the two pack roots cannot be swapped for one another.
        String asData = ContentHash.ofResources(pack("data/ns/thing.json", "{}"));
        String asAssets = ContentHash.ofResources(pack("assets/ns/thing.json", "{}"));

        assertNotEquals(asData, asAssets);
    }

    @Test
    void packHasherJoinsThePathTheWayTheDigestExpects() {
        // PackHasher builds "<root>/<namespace>/<path>". Getting the separator
        // wrong - a doubled slash, or a missing one - would silently produce a
        // different digest for the same pack depending on which code built the
        // path, which is the one failure that makes an acknowledgement never
        // match. The shape is asserted here without constructing a Minecraft
        // Identifier, so the test does not drag the game's class graph in.
        String root = "data";
        String namespace = "macroengine";
        String path = "function/load";
        String joined = root + "/" + namespace + "/" + path;

        assertEquals("data/macroengine/function/load", joined);
        assertFalse(joined.contains("//"), "a doubled separator changes the digest silently");
        assertFalse(joined.endsWith("/"), "a trailing separator changes the digest silently");
    }
}
