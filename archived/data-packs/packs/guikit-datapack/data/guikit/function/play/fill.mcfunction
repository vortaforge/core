execute unless score #guikit.open vortaforge.gate matches 1 run return 0
execute if entity @s[type=minecraft:player] unless entity @s[tag=guikit.consented] unless score #guikit.gate.3 vortaforge.gate matches 0 run return 0
function guikit:runtime/ensure_pid
function guikit:widget/pad
data modify storage guikit:work menu_id set from storage guikit:sess cur.menu
execute store result storage guikit:work page int 1 run scoreboard players get @s guikit.page
function guikit:play/fill_load with storage guikit:work
function guikit:play/refresh_rate
