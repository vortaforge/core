# ======================================================================================
# macroengine:input/private/lectern_capture  [INTERNAL]
# MC 26.3 (release; data pack 121.0): Book.components writable/written_book_content pages as {raw}|{text}|string
# ======================================================================================

execute unless score #macroengine.open vortaforge.gate matches 1 run return 0
execute if entity @s[type=minecraft:player] unless entity @s[tag=macroengine.consented] unless score #macroengine.gate.3 vortaforge.gate matches 0 run return 0
data modify storage macroengine:input lectern.raw set value ""

data modify storage macroengine:input lectern.raw set from block ~ ~ ~ Book.components."minecraft:writable_book_content".pages[0].raw
execute if data storage macroengine:input {lectern:{raw:""}} run data modify storage macroengine:input lectern.raw set from block ~ ~ ~ Book.components."minecraft:writable_book_content".pages[0].text
execute if data storage macroengine:input {lectern:{raw:""}} run data modify storage macroengine:input lectern.raw set from block ~ ~ ~ Book.components."minecraft:writable_book_content".pages[0]

execute if data storage macroengine:input {lectern:{raw:""}} run data modify storage macroengine:input lectern.raw set from block ~ ~ ~ Book.components."minecraft:written_book_content".pages[0].raw
execute if data storage macroengine:input {lectern:{raw:""}} run data modify storage macroengine:input lectern.raw set from block ~ ~ ~ Book.components."minecraft:written_book_content".pages[0].text
execute if data storage macroengine:input {lectern:{raw:""}} run data modify storage macroengine:input lectern.raw set from block ~ ~ ~ Book.components."minecraft:written_book_content".pages[0]

data modify storage macroengine:input lectern.player set from entity @s UUID
data modify storage macroengine:input lectern.pos set from entity @s Pos
data modify storage macroengine:input lectern.executed set value 0b
# Prompt-injection screening (data-only; docs/prompt_injection.md) - runs before listeners fire.
data modify storage macroengine:input_validate scan_in set value {kind:"lectern"}
data modify storage macroengine:input_validate scan_in.text set from storage macroengine:input lectern.raw
function macroengine:input/validate/injection_scan
data modify storage macroengine:input lectern.scan set from storage macroengine:input_validate scan
execute if data storage macroengine:input_validate scan{suspicious:1b} run function macroengine:core/internal/input/validate/_private/injection_report
execute if data storage macroengine:input lectern{executed:0b} run function #macroengine:input/lectern
