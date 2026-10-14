# macro: $(id)     id is always m<number>, never player text
execute unless score #guikit.open vortaforge.gate matches 1 run return 0
execute if entity @s[type=minecraft:player] unless entity @s[tag=guikit.consented] unless score #guikit.gate.3 vortaforge.gate matches 0 run return 0
$data modify storage guikit:work menu set from storage guikit:lib menus.$(id)
execute unless data storage guikit:work menu run return 0
execute store result score #n guikit.tmp run data get storage guikit:work menu.n
execute store result storage guikit:work n int 1 run scoreboard players get #n guikit.tmp
$data modify storage guikit:work id set value "$(id)"
function guikit:runtime/sync_container
function guikit:runtime/sync_put with storage guikit:work
