execute unless score #guikit.open vortaforge.gate matches 1 run return 0
execute if entity @s[type=minecraft:player] unless entity @s[tag=guikit.consented] unless score #guikit.gate.3 vortaforge.gate matches 0 run return 0
tag @s remove guikit.preview
function guikit:editor/load_state
function guikit:play/open_id with storage guikit:ed cur
tellraw @s [{"text":"[guikit] Preview. ","color":"gray"},{"text":"Return to the editor","color":"aqua","click_event":{"action":"suggest_command","command":"/function guikit:editor/resume"}}]
