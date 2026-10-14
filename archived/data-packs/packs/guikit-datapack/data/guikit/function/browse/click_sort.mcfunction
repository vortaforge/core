execute unless score #guikit.open vortaforge.gate matches 1 run return 0
execute if entity @s[type=minecraft:player] unless entity @s[tag=guikit.consented] unless score #guikit.gate.3 vortaforge.gate matches 0 run return 0
scoreboard players set #want guikit.tmp 1
function guikit:browse/apply_sort
scoreboard players set @s guikit.bpage 0
scoreboard players set @s guikit.dirty 1
function guikit:browse/tell_sort
