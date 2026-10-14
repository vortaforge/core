# as player. Reward of guard_click (right click) and guard_attack (left click).
execute unless score #guikit.open vortaforge.gate matches 1 run return 0
execute if entity @s[type=minecraft:player] unless entity @s[tag=guikit.consented] unless score #guikit.gate.3 vortaforge.gate matches 0 run return 0
advancement revoke @s only guikit:guard_click
advancement revoke @s only guikit:guard_attack
tag @s add guikit.gclick
execute as @e[type=minecraft:interaction,tag=guikit.guard,distance=..8] run function guikit:internal/guard/match_click
tag @s remove guikit.gclick
