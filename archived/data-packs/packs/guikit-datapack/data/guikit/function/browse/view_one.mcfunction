# macro: $(id)
execute unless score #guikit.open vortaforge.gate matches 1 run return 0
execute if entity @s[type=minecraft:player] unless entity @s[tag=guikit.consented] unless score #guikit.gate.3 vortaforge.gate matches 0 run return 0
data remove storage guikit:work menu
$data modify storage guikit:work menu set from storage guikit:lib menus.$(id)
execute unless data storage guikit:work menu run return 0
execute if data storage guikit:work menu{published:0b} run return 0
function guikit:browse/filter_ok
execute unless score #pass guikit.tmp matches 1 run return 0
data modify storage guikit:work view append from storage guikit:work id
