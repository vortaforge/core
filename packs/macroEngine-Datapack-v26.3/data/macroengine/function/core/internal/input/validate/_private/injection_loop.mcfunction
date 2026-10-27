# macroengine:core/internal/input/validate/_private/injection_loop [INTERNAL]
# One pattern per call: pops scan_patterns[0], searches scan_work for its
# needle with the data-only text engine, records the hit, recurses. Stops
# once 2 strong hits are on record - the classification is decided and the
# remaining patterns would only spend command budget (see COST BOUND in
# input/validate/injection_scan). The text is only compared as data.
execute unless score #macroengine.open vortaforge.gate matches 1 run return 0
execute if entity @s[type=minecraft:player] unless entity @s[tag=macroengine.consented] unless score #macroengine.gate.3 vortaforge.gate matches 0 run return 0
execute if score #inj_hits macroengine.tmp matches 2.. run return 1
execute unless data storage macroengine:input_validate scan_patterns[0] run return 1
data modify storage macroengine:input_validate cur set from storage macroengine:input_validate scan_patterns[0]
data remove storage macroengine:input_validate scan_patterns[0]
data modify storage macroengine:input string set from storage macroengine:input_validate scan_work
data modify storage macroengine:input find set from storage macroengine:input_validate cur.needle
data modify storage macroengine:input n set value 1
function macroengine:core/lib/string/find
scoreboard players set #inj_idx macroengine.tmp -1
execute store result score #inj_idx macroengine.tmp run data get storage macroengine:output string.result[0]
execute if score #inj_idx macroengine.tmp matches 0.. run function macroengine:core/internal/input/validate/_private/injection_hit
function macroengine:core/internal/input/validate/_private/injection_loop
return 1
