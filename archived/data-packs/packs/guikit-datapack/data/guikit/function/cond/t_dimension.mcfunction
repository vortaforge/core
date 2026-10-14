# macro: $(dim)
# Passes when the player currently is in that dimension (minecraft:overworld, minecraft:the_nether,
# minecraft:the_end, or any modded/custom dimension id). `at @s` moves the execution context to the
# player, so the check is correct no matter where the caller was running.
execute unless score #guikit.open vortaforge.gate matches 1 run return 0
execute if entity @s[type=minecraft:player] unless entity @s[tag=guikit.consented] unless score #guikit.gate.3 vortaforge.gate matches 0 run return 0
$execute at @s if dimension $(dim) run scoreboard players set #cond guikit.tmp 1
