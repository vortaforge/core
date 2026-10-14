# macro: $(cmd)     as player
# Runs with the permission level datapack functions get (function-permission-level, default 2),
# not the player's own. cmd must come from menu code / definitions, never from player input.
execute unless score #guikit.open vortaforge.gate matches 1 run return 0
execute if entity @s[type=minecraft:player] unless entity @s[tag=guikit.consented] unless score #guikit.gate.3 vortaforge.gate matches 0 run return 0
$execute as @s at @s run $(cmd)
