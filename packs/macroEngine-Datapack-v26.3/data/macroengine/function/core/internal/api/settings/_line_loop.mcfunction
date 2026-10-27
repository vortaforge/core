# macroengine:core/internal/api/settings/_line_loop [INTERNAL]

execute unless score #macroengine.open vortaforge.gate matches 1 run return 0
execute if entity @s[type=minecraft:player] unless entity @s[tag=macroengine.consented] unless score #macroengine.gate.3 vortaforge.gate matches 0 run return 0
execute unless data storage macroengine:settings tmp.lines[0] run return 0
data modify storage macroengine:settings tmp.line set from storage macroengine:settings tmp.lines[0]
data remove storage macroengine:settings tmp.lines[0]
function macroengine:core/internal/api/settings/_line
function macroengine:core/internal/api/settings/_line_loop
return 1
