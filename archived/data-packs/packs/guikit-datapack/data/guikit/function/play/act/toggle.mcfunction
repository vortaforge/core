execute unless score #guikit.open vortaforge.gate matches 1 run return 0
execute if entity @s[type=minecraft:player] unless entity @s[tag=guikit.consented] unless score #guikit.gate.3 vortaforge.gate matches 0 run return 0
execute store result storage guikit:work pid int 1 run scoreboard players get @s guikit.pid
data modify storage guikit:work key set from storage guikit:work w.key
function guikit:play/act/toggle_do with storage guikit:work
scoreboard players set @s guikit.dirty 1
