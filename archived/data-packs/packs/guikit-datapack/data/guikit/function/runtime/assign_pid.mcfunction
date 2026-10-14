execute unless score #guikit.open vortaforge.gate matches 1 run return 0
execute if entity @s[type=minecraft:player] unless entity @s[tag=guikit.consented] unless score #guikit.gate.3 vortaforge.gate matches 0 run return 0
execute unless score #next_pid guikit.const matches 1.. run scoreboard players set #next_pid guikit.const 1
scoreboard players operation @s guikit.pid = #next_pid guikit.const
scoreboard players add #next_pid guikit.const 1
