# macro: $(sound) $(volume) $(pitch)     as player, at player
# `ui` category so it follows the client's "Master" slider only, not music/blocks/hostile.
execute unless score #guikit.open vortaforge.gate matches 1 run return 0
execute if entity @s[type=minecraft:player] unless entity @s[tag=guikit.consented] unless score #guikit.gate.3 vortaforge.gate matches 0 run return 0
$playsound $(sound) ui @s ~ ~ ~ $(volume) $(pitch)
