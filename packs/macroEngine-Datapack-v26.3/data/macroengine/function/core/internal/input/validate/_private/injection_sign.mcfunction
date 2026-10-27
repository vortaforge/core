# macroengine:core/internal/input/validate/_private/injection_sign [INTERNAL]
# Screens the captured sign lines (a payload does not have to sit on the
# first non-empty line that sign.raw points at) under one shared character
# budget - the same 96 the single-text scan enforces - and aggregates the
# result into macroengine:input sign.scan, then reports a strong hit.
# Called by input/private/sign_capture before the input tag fires.
execute unless score #macroengine.open vortaforge.gate matches 1 run return 0
execute if entity @s[type=minecraft:player] unless entity @s[tag=macroengine.consented] unless score #macroengine.gate.3 vortaforge.gate matches 0 run return 0
data modify storage macroengine:input sign.scan set value {suspicious:0b,watch:0b,fold_failed:0b,truncated:0b,strong_count:0,hits:[]}
data modify storage macroengine:input_validate scan_lines set from storage macroengine:input sign.lines
data modify storage macroengine:input_validate scan_in set value {kind:"sign"}
scoreboard players set #inj_budget macroengine.tmp 0
scoreboard players set #inj_scc macroengine.tmp 0
function macroengine:core/internal/input/validate/_private/injection_sign_loop
data remove storage macroengine:input_validate scan_lines
data remove storage macroengine:input_validate scan_line
data modify storage macroengine:input_validate scan set from storage macroengine:input sign.scan
execute if data storage macroengine:input sign.scan{suspicious:1b} run function macroengine:core/internal/input/validate/_private/injection_report
return 1
