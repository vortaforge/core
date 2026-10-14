execute unless score #guikit.open vortaforge.gate matches 1 run return 0
execute if entity @s[type=minecraft:player] unless entity @s[tag=guikit.consented] unless score #guikit.gate.3 vortaforge.gate matches 0 run return 0
scoreboard players add @s guikit.bfilt 1
execute unless score @s guikit.bfilt matches 0..7 run scoreboard players set @s guikit.bfilt 0
