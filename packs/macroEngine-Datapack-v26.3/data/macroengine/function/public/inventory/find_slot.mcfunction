# macroengine:public/inventory/find_slot
execute unless score #macroengine.open vortaforge.gate matches 1 run return 0
execute if entity @s[type=minecraft:player] unless entity @s[tag=macroengine.consented] unless score #macroengine.gate.3 vortaforge.gate matches 0 run return 0
execute unless data storage macroengine:input inventory.player run return 0
execute unless data storage macroengine:input inventory.custom_data run return 0
# FIX (v26.3-r1): used to return slot -1 (a valid-looking "not found") because
# internal/inventory/_find_slot_exec is an empty stub. Now explicitly unsupported.
function macroengine:internal/inventory/_find_slot_exec with storage macroengine:input inventory
data modify storage macroengine:output inventory set value {slot:-1,supported:0b,error:"inventory engine not implemented in this build"}
return 0
