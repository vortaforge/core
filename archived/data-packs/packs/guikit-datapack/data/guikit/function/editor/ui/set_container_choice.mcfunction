# macro: $(container)
execute unless score #guikit.open vortaforge.gate matches 1 run return 0
execute if entity @s[type=minecraft:player] unless entity @s[tag=guikit.consented] unless score #guikit.gate.3 vortaforge.gate matches 0 run return 0
function guikit:editor/load_state
$function guikit:editor/ui/settings_container {container:"$(container)"}
data modify storage guikit:work id set from storage guikit:ed cur.menu
function guikit:runtime/sync_one with storage guikit:work
function guikit:editor/save_state
tellraw @s {"text":"[guikit] Container updated. Preview to see it.","color":"green"}
function guikit:editor/schedule_resume
