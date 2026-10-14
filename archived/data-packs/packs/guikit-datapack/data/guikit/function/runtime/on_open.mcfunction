# guikit :: runtime/on_open     as player, uid already assigned, before the first redraw
execute unless score #guikit.open vortaforge.gate matches 1 run return 0
execute if entity @s[type=minecraft:player] unless entity @s[tag=guikit.consented] unless score #guikit.gate.3 vortaforge.gate matches 0 run return 0
execute unless data storage guikit:ed pending.mode run return 0
execute store result storage guikit:ctx uid int 1 run scoreboard players get @s guikit.uid
data modify storage guikit:ctx mode set from storage guikit:ed pending.mode
data modify storage guikit:ctx menu set from storage guikit:ed pending.menu
data modify storage guikit:ctx alias set from storage guikit:ed pending.alias
function guikit:runtime/bind with storage guikit:ctx
