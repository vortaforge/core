# macroengine:core/internal/input/validate/_private/injection_sign_loop [INTERNAL]
# One sign line per call: scans it (within the shared 96-char budget) and
# merges into sign.scan, recurses. Lines past the budget are reported via
# sign.scan.truncated instead of being scanned - see COST BOUND in
# input/validate/injection_scan.
execute unless score #macroengine.open vortaforge.gate matches 1 run return 0
execute if entity @s[type=minecraft:player] unless entity @s[tag=macroengine.consented] unless score #macroengine.gate.3 vortaforge.gate matches 0 run return 0
execute unless data storage macroengine:input_validate scan_lines[0] run return 1
data modify storage macroengine:input_validate scan_in.text set from storage macroengine:input_validate scan_lines[0]
data remove storage macroengine:input_validate scan_lines[0]
# Coerce before measuring: a text-component line must count by characters,
# not by compound keys, or the shared budget stops being a budget.
data remove storage macroengine:input_validate scan_line
data modify storage macroengine:input_validate scan_line set string storage macroengine:input_validate scan_in.text
data modify storage macroengine:input_validate scan_in.text set from storage macroengine:input_validate scan_line
execute if data storage macroengine:input_validate scan_in{text:""} run function macroengine:core/internal/input/validate/_private/injection_sign_loop
execute if data storage macroengine:input_validate scan_in{text:""} run return 1
execute if score #inj_budget macroengine.tmp matches 96.. run data modify storage macroengine:input sign.scan.truncated set value 1b
execute if score #inj_budget macroengine.tmp matches 96.. run data modify storage macroengine:input sign.scan.watch set value 1b
execute if score #inj_budget macroengine.tmp matches 96.. run return 1
execute store result score #inj_line_len macroengine.tmp run data get storage macroengine:input_validate scan_in.text
scoreboard players operation #inj_budget macroengine.tmp += #inj_line_len macroengine.tmp
function macroengine:input/validate/injection_scan
data modify storage macroengine:input sign.scan.hits append from storage macroengine:input_validate scan.hits[]
execute if data storage macroengine:input_validate scan{suspicious:1b} run data modify storage macroengine:input sign.scan.suspicious set value 1b
execute if data storage macroengine:input_validate scan{watch:1b} run data modify storage macroengine:input sign.scan.watch set value 1b
execute if data storage macroengine:input_validate scan{fold_failed:1b} run data modify storage macroengine:input sign.scan.fold_failed set value 1b
execute if data storage macroengine:input_validate scan{truncated:1b} run data modify storage macroengine:input sign.scan.truncated set value 1b
execute store result score #inj_line macroengine.tmp run data get storage macroengine:input_validate scan.strong_count
scoreboard players operation #inj_scc macroengine.tmp += #inj_line macroengine.tmp
execute store result storage macroengine:input sign.scan.strong_count int 1 run scoreboard players get #inj_scc macroengine.tmp
function macroengine:core/internal/input/validate/_private/injection_sign_loop
return 1
