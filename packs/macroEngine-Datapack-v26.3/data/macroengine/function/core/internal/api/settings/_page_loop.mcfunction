# macroengine:core/internal/api/settings/_page_loop [INTERNAL]
# Collects the text of every page in tmp.pages into tmp.chunks. A page
# element is normally {raw:"..."}; the .text and plain-string forms are
# accepted too, the same fallbacks input/private/lectern_capture uses.

execute unless score #macroengine.open vortaforge.gate matches 1 run return 0
execute if entity @s[type=minecraft:player] unless entity @s[tag=macroengine.consented] unless score #macroengine.gate.3 vortaforge.gate matches 0 run return 0
execute unless data storage macroengine:settings tmp.pages[0] run return 0
data remove storage macroengine:settings tmp.chunk
execute if data storage macroengine:settings tmp.pages[0].raw run data modify storage macroengine:settings tmp.chunks append from storage macroengine:settings tmp.pages[0].raw
execute unless data storage macroengine:settings tmp.pages[0].raw if data storage macroengine:settings tmp.pages[0].text run data modify storage macroengine:settings tmp.chunks append from storage macroengine:settings tmp.pages[0].text
execute unless data storage macroengine:settings tmp.pages[0].raw unless data storage macroengine:settings tmp.pages[0].text run data modify storage macroengine:settings tmp.chunk set string storage macroengine:settings tmp.pages[0]
execute if data storage macroengine:settings tmp.chunk run data modify storage macroengine:settings tmp.chunks append from storage macroengine:settings tmp.chunk
data remove storage macroengine:settings tmp.pages[0]
function macroengine:core/internal/api/settings/_page_loop
return 1
