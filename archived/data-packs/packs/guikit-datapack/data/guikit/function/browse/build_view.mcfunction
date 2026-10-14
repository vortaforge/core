# published menus only, then this player's sort and container filter
execute unless score #guikit.open vortaforge.gate matches 1 run return 0
execute if entity @s[type=minecraft:player] unless entity @s[tag=guikit.consented] unless score #guikit.gate.3 vortaforge.gate matches 0 run return 0
data modify storage guikit:work src set from storage guikit:lib order
data modify storage guikit:work view set value []
execute if score @s guikit.bsort matches 1 run function guikit:browse/reverse_src
function guikit:browse/view_loop
