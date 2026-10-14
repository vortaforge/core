# default 1 second. A stored 0 / 60 / 100 overrides it. Editor chest sets 0 itself.
execute unless score #guikit.open vortaforge.gate matches 1 run return 0
execute if entity @s[type=minecraft:player] unless entity @s[tag=guikit.consented] unless score #guikit.gate.3 vortaforge.gate matches 0 run return 0
scoreboard players set @s guikit.rfiv 20
execute if data storage guikit:work menu{refresh:0} run scoreboard players set @s guikit.rfiv 0
execute if data storage guikit:work menu{refresh:60} run scoreboard players set @s guikit.rfiv 60
execute if data storage guikit:work menu{refresh:100} run scoreboard players set @s guikit.rfiv 100
