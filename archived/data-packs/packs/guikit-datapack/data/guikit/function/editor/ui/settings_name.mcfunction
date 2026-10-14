# macro: $(name)
execute unless score #guikit.open vortaforge.gate matches 1 run return 0
execute if entity @s[type=minecraft:player] unless entity @s[tag=guikit.consented] unless score #guikit.gate.3 vortaforge.gate matches 0 run return 0
$data modify storage guikit:ed name_in set value "$(name)"
function guikit:editor/ui/settings_name_put with storage guikit:ed cur
data remove storage guikit:ed name_in
