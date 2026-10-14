# macro: $(obj) $(amount)
execute unless score #guikit.open vortaforge.gate matches 1 run return 0
execute if entity @s[type=minecraft:player] unless entity @s[tag=guikit.consented] unless score #guikit.gate.3 vortaforge.gate matches 0 run return 0
scoreboard players set #paid guikit.tmp 0
$execute if score @s $(obj) matches $(amount).. run scoreboard players set #paid guikit.tmp 1
$execute if score #paid guikit.tmp matches 1 run scoreboard players remove @s $(obj) $(amount)
