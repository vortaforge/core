# macro: $(obj) $(n) $(last)
execute unless score #guikit.open vortaforge.gate matches 1 run return 0
execute if entity @s[type=minecraft:player] unless entity @s[tag=guikit.consented] unless score #guikit.gate.3 vortaforge.gate matches 0 run return 0
$execute unless score @s $(obj) matches 0.. run scoreboard players set @s $(obj) 0
$scoreboard players add @s $(obj) 1
$execute if score @s $(obj) matches $(n).. if data storage guikit:in {wrap:1b} run scoreboard players set @s $(obj) 0
$execute if score @s $(obj) matches $(n).. unless data storage guikit:in {wrap:1b} run scoreboard players set @s $(obj) $(last)
