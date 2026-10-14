execute unless score #guikit.open vortaforge.gate matches 1 run return 0
execute if entity @s[type=minecraft:player] unless entity @s[tag=guikit.consented] unless score #guikit.gate.3 vortaforge.gate matches 0 run return 0
function guikit:editor/load_state
execute store result score #page guikit.tmp run data get storage guikit:ed cur.list_page
scoreboard players add #page guikit.tmp 1
execute store result storage guikit:ed cur.list_page int 1 run scoreboard players get #page guikit.tmp
function guikit:editor/save_state
scoreboard players set @s guikit.dirty 1
