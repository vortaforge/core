execute unless score #guikit.open vortaforge.gate matches 1 run return 0
execute if entity @s[type=minecraft:player] unless entity @s[tag=guikit.consented] unless score #guikit.gate.3 vortaforge.gate matches 0 run return 0
data modify storage guikit:work menu set from storage guikit:work w.to
function guikit:play/open_id with storage guikit:work
