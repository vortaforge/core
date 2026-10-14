# macro: $(weather)
# Passes when the weather in the player's dimension matches: clear | rain | thunder.
# `at @s` moves the execution context to the player, so a nether menu still reads the overworld's
# sky correctly for players standing in the overworld, and vice versa.
execute unless score #guikit.open vortaforge.gate matches 1 run return 0
execute if entity @s[type=minecraft:player] unless entity @s[tag=guikit.consented] unless score #guikit.gate.3 vortaforge.gate matches 0 run return 0
$execute at @s if weather $(weather) run scoreboard players set #cond guikit.tmp 1
