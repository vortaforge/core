# macroengine:internal/inventory/_find_slot_exec
# FIX (v26.3-r1): comment-only stub — public/inventory/find_slot always returned
# slot -1, which reads as "player has no such item" even when they do.
scoreboard players set #macroengine.inv_slot macroengine.tmp -1
execute if data storage macroengine:input inventory run data modify storage macroengine:output inventory set value {slot:-1,supported:0b,error:"inventory engine not implemented in this build"}
return 0
