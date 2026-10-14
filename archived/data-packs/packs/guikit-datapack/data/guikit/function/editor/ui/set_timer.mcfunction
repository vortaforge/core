# macro: $(seconds)
execute unless score #guikit.open vortaforge.gate matches 1 run return 0
execute if entity @s[type=minecraft:player] unless entity @s[tag=guikit.consented] unless score #guikit.gate.3 vortaforge.gate matches 0 run return 0
function guikit:editor/load_state
$scoreboard players set #sec guikit.tmp $(seconds)
scoreboard players set #t20 guikit.tmp 20
scoreboard players operation #sec guikit.tmp *= #t20 guikit.tmp
execute store result storage guikit:work ticks int 1 run scoreboard players get #sec guikit.tmp
function guikit:editor/ui/settings_timer with storage guikit:ed cur
data modify storage guikit:work id set from storage guikit:ed cur.menu
function guikit:runtime/sync_one with storage guikit:work
function guikit:editor/save_state
tellraw @s {"text":"[guikit] Timeout updated.","color":"green"}
function guikit:editor/schedule_resume
