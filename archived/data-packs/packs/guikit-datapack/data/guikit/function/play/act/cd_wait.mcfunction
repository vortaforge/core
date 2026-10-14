execute unless score #guikit.open vortaforge.gate matches 1 run return 0
execute if entity @s[type=minecraft:player] unless entity @s[tag=guikit.consented] unless score #guikit.gate.3 vortaforge.gate matches 0 run return 0
scoreboard players set #blocked guikit.tmp 1
scoreboard players operation #secs guikit.tmp = #left guikit.tmp
scoreboard players add #secs guikit.tmp 19
scoreboard players set #twenty guikit.tmp 20
scoreboard players operation #secs guikit.tmp /= #twenty guikit.tmp
execute if score #secs guikit.tmp matches ..0 run scoreboard players set #secs guikit.tmp 1
tellraw @s [{"text":"[GUI] ","color":"gray"},{"text":"Wait ","color":"red"},{"score":{"name":"#secs","objective":"guikit.tmp"},"color":"red"},{"text":"s.","color":"red"}]
