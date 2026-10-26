# Module toggle guard — skips this module when disabled via macroengine:public/toggle/perm/false
execute unless score #macroengine.open vortaforge.gate matches 1 run return 0
execute if entity @s[type=minecraft:player] unless entity @s[tag=macroengine.consented] unless score #macroengine.gate.3 vortaforge.gate matches 0 run return 0
execute unless data storage macroengine:engine {modules:{perm:1b}} run return 0
scoreboard players operation #macroengine.scan_mod macroengine.tick = #macroengine.tick_ctr macroengine.tick
scoreboard players operation #macroengine.scan_mod macroengine.tick %= #macroengine.perm_trigger_interval macroengine.tick
execute unless score #macroengine.scan_mod macroengine.tick matches 0 run return 0

execute unless data storage macroengine:engine perm_trigger_names[0] run return 0

data modify storage macroengine:engine _pt_names_tmp set from storage macroengine:engine perm_trigger_names
function macroengine:internal/_api/perm/trigger/tick_step_loop
data remove storage macroengine:engine _pt_names_tmp
