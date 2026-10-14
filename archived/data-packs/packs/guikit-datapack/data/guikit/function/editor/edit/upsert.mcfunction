# writes guikit:ed widget into the current page, replacing the same slot
execute unless score #guikit.open vortaforge.gate matches 1 run return 0
execute if entity @s[type=minecraft:player] unless entity @s[tag=guikit.consented] unless score #guikit.gate.3 vortaforge.gate matches 0 run return 0
function guikit:editor/read_menu
execute store result storage guikit:work page int 1 run data get storage guikit:ed cur.page
function guikit:editor/edit/load_src with storage guikit:work
data modify storage guikit:work out set value []
function guikit:editor/edit/upsert_loop
data modify storage guikit:work out append from storage guikit:ed widget
function guikit:editor/edit/upsert_write with storage guikit:ed cur
