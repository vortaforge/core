execute unless score #guikit.open vortaforge.gate matches 1 run return 0
execute if entity @s[type=minecraft:player] unless entity @s[tag=guikit.consented] unless score #guikit.gate.3 vortaforge.gate matches 0 run return 0
scoreboard players set #blocked guikit.tmp 1
tellraw @s [{"text":"[GUI] ","color":"gray"},{"text":"You need the staff tag for this button.","color":"red"}]
