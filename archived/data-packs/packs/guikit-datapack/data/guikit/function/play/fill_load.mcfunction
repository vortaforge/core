# macro: $(menu_id) $(page)
execute unless score #guikit.open vortaforge.gate matches 1 run return 0
execute if entity @s[type=minecraft:player] unless entity @s[tag=guikit.consented] unless score #guikit.gate.3 vortaforge.gate matches 0 run return 0
data remove storage guikit:work menu
$data modify storage guikit:work menu set from storage guikit:lib menus.$(menu_id)
execute unless data storage guikit:work menu run return 0
execute store result storage guikit:work n int 1 run data get storage guikit:work menu.n
data remove storage guikit:work src
$data modify storage guikit:work src set from storage guikit:work menu.pages[$(page)].widgets
execute unless data storage guikit:work src run data modify storage guikit:work src set value []
function guikit:play/draw_loop
