execute unless score #guikit.open vortaforge.gate matches 1 run return 0
execute if entity @s[type=minecraft:player] unless entity @s[tag=guikit.consented] unless score #guikit.gate.3 vortaforge.gate matches 0 run return 0
function guikit:editor/load_state
execute store result storage guikit:ed cur.slot int 1 run scoreboard players get #eslot guikit.tmp
data modify storage guikit:ed cur.dialog set value "slot"
function guikit:editor/save_state
function guikit:api/close
function guikit:editor/schedule_dialog
