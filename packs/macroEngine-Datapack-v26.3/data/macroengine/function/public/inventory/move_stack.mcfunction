# macroengine:public/inventory/move_stack
execute unless score #macroengine.open vortaforge.gate matches 1 run return 0
execute if entity @s[type=minecraft:player] unless entity @s[tag=macroengine.consented] unless score #macroengine.gate.3 vortaforge.gate matches 0 run return 0
execute unless data storage macroengine:input inventory.player run return 0
execute unless data storage macroengine:input inventory.from_slot run return 0
# FIX (v26.3-r1): both move paths were comment-only stubs, so this call moved
# nothing and reported nothing. It now fails closed with a visible flag.
data modify storage macroengine:output inventory set value {moved:0b,supported:0b,error:"inventory engine not implemented in this build"}
return 0
