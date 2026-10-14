execute unless score #guikit.open vortaforge.gate matches 1 run return 0
execute if entity @s[type=minecraft:player] unless entity @s[tag=guikit.consented] unless score #guikit.gate.3 vortaforge.gate matches 0 run return 0
execute unless data storage guikit:work list[0] run return 0
execute if score #drawn guikit.tmp matches 18.. run return 0
data modify storage guikit:work id set from storage guikit:work list[0]
function guikit:browse/draw_one with storage guikit:work
data remove storage guikit:work list[0]
function guikit:browse/draw_loop
