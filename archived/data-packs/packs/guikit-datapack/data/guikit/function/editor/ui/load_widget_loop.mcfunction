execute unless score #guikit.open vortaforge.gate matches 1 run return 0
execute if entity @s[type=minecraft:player] unless entity @s[tag=guikit.consented] unless score #guikit.gate.3 vortaforge.gate matches 0 run return 0
execute unless data storage guikit:work src[0] run return 0
execute store result score #a guikit.tmp run data get storage guikit:work src[0].slot
execute store result score #b guikit.tmp run data get storage guikit:ed cur.slot
execute if score #a guikit.tmp = #b guikit.tmp run data modify storage guikit:ed widget set from storage guikit:work src[0]
execute if score #a guikit.tmp = #b guikit.tmp run scoreboard players set #ok guikit.tmp 1
execute if score #a guikit.tmp = #b guikit.tmp run return 0
data remove storage guikit:work src[0]
function guikit:editor/ui/load_widget_loop
