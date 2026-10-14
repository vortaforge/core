# macro: $(slot) $(cell) $(item) $(id) $(name)
# Same shape as internal/progress_slot, but type "meter" (clickable) and the cell's id is
# "<id>_<cell>" so widget/meter_probe can test each cell individually.
execute unless score #guikit.open vortaforge.gate matches 1 run return 0
execute if entity @s[type=minecraft:player] unless entity @s[tag=guikit.consented] unless score #guikit.gate.3 vortaforge.gate matches 0 run return 0
$scoreboard players set #abs guikit.tmp $(slot)
$scoreboard players add #abs guikit.tmp $(cell)
execute store result storage guikit:pg abs int 1 run scoreboard players get #abs guikit.tmp
$data modify storage guikit:w item set value "$(item)"
$data modify storage guikit:w id set value "$(id)_$(cell)"
data modify storage guikit:w type set value "meter"
$data modify storage guikit:w name set value '$(name)'
data modify storage guikit:w slot set from storage guikit:pg abs
data modify storage guikit:w lore set value []
function guikit:widget/draw
