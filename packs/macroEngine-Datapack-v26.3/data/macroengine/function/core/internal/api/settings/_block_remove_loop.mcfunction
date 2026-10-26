# macroengine:core/internal/api/settings/_block_remove_loop [INTERNAL]

execute unless score #macroengine.open vortaforge.gate matches 1 run return 0
execute if entity @s[type=minecraft:player] unless entity @s[tag=macroengine.consented] unless score #macroengine.gate.3 vortaforge.gate matches 0 run return 0
execute unless data storage macroengine:settings tmp.pending[0] run return 0
data modify storage macroengine:settings tmp.cmp set from storage macroengine:settings tmp.root
execute store success score #stbk_diff macroengine.tmp run data modify storage macroengine:settings tmp.cmp set from storage macroengine:settings tmp.pending[0]
execute if score #stbk_diff macroengine.tmp matches 1 run data modify storage macroengine:settings tmp.kept append from storage macroengine:settings tmp.pending[0]
data remove storage macroengine:settings tmp.pending[0]
function macroengine:core/internal/api/settings/_block_remove_loop
return 1
