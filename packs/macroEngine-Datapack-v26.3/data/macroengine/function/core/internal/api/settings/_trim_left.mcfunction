# macroengine:core/internal/api/settings/_trim_left [INTERNAL]
# Drops leading spaces from tmp.str, in place, using data-modify string
# slicing only (the string library is not needed for one character).

execute unless score #macroengine.open vortaforge.gate matches 1 run return 0
execute if entity @s[type=minecraft:player] unless entity @s[tag=macroengine.consented] unless score #macroengine.gate.3 vortaforge.gate matches 0 run return 0
data remove storage macroengine:settings tmp.first
data modify storage macroengine:settings tmp.first set string storage macroengine:settings tmp.str 0 1
execute unless data storage macroengine:settings tmp{first:" "} run return 1
data modify storage macroengine:settings tmp.str set string storage macroengine:settings tmp.str 1
function macroengine:core/internal/api/settings/_trim_left
return 1
