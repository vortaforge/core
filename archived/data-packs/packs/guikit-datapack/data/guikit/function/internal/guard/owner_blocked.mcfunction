# Owner clicked the guard. Someone else is in range — do not hide it.
execute unless score #guikit.open vortaforge.gate matches 1 run return 0
execute if entity @s[type=minecraft:player] unless entity @s[tag=guikit.consented] unless score #guikit.gate.3 vortaforge.gate matches 0 run return 0
execute if score @s guikit.gmsg matches 1.. run return 0
scoreboard players set @s guikit.gmsg 20
tellraw @s [{"text":"[guikit] ","color":"gray"},{"text":"Someone is too close, so this menu is locked. It opens again when they step away.","color":"gold"}]
