# macroengine:core/internal/api/settings/_chunk_loop [INTERNAL]
# Splits one page text (tmp.chunks[0]) into lines and feeds them to the
# line parser, page by page. The string library handles the split while
# the text is still data; no book text is ever substituted into a macro.

execute unless score #macroengine.open vortaforge.gate matches 1 run return 0
execute if entity @s[type=minecraft:player] unless entity @s[tag=macroengine.consented] unless score #macroengine.gate.3 vortaforge.gate matches 0 run return 0
execute unless data storage macroengine:settings tmp.chunks[0] run return 0
data remove storage macroengine:input string
data remove storage macroengine:input separator
data remove storage macroengine:input n
data remove storage macroengine:input keep_empty
data modify storage macroengine:input string set from storage macroengine:settings tmp.chunks[0]
data modify storage macroengine:input separator set value "\n"
function macroengine:core/lib/string/split
data remove storage macroengine:settings tmp.lines
data modify storage macroengine:settings tmp.lines set from storage macroengine:output string.result
function macroengine:core/internal/api/settings/_line_loop
data remove storage macroengine:settings tmp.chunks[0]
function macroengine:core/internal/api/settings/_chunk_loop
return 1
