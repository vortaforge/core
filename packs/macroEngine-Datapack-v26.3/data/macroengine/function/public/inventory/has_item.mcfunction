# macroengine:public/inventory/has_item
# Thin wrapper — player inventory item count
execute unless score #macroengine.open vortaforge.gate matches 1 run return 0
execute if entity @s[type=minecraft:player] unless entity @s[tag=macroengine.consented] unless score #macroengine.gate.3 vortaforge.gate matches 0 run return 0
execute unless data storage macroengine:input inventory.player run return 0
execute unless data storage macroengine:input inventory.custom_data run return 0
# FIX (v26.3-r1): the counting engine (internal/inventory/_has_item_exec) is an
# unimplemented stub in this build, so this call used to report count 0 for
# every player and every item — indistinguishable from "you have none".
# It now returns supported:0b plus an error string instead of a fake 0.
function macroengine:internal/inventory/_has_item_exec with storage macroengine:input inventory
data modify storage macroengine:output inventory set value {count:0,supported:0b,error:"inventory engine not implemented in this build"}
return 0
