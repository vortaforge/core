# macroengine:internal/inventory/_has_item_exec
# FIX (v26.3-r1): this file used to be comment-only, so public/inventory/has_item
# always reported count 0 for every player and every item. The counting engine
# is not implemented in this build; fail closed and say so instead of returning
# a plausible-looking 0.
execute if data storage macroengine:input inventory run data modify storage macroengine:output inventory set value {count:0,supported:0b,error:"inventory engine not implemented in this build"}
scoreboard players set #macroengine.inv_count macroengine.tmp 0
return 0
