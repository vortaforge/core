# macroengine:core/internal/api/settings/_block_has_loop [INTERNAL]
# Sets tmp.found when tmp.root occurs in tmp.pending, using the same
# data-modify equality trick as systems/cmd_gate/_block_loop.

execute unless score #macroengine.open vortaforge.gate matches 1 run return 0
execute if entity @s[type=minecraft:player] unless entity @s[tag=macroengine.consented] unless score #macroengine.gate.3 vortaforge.gate matches 0 run return 0
execute unless data storage macroengine:settings tmp.pending[0] run return 0
data modify storage macroengine:settings tmp.cmp set from storage macroengine:settings tmp.root
execute store success score #stbk_diff macroengine.tmp run data modify storage macroengine:settings tmp.cmp set from storage macroengine:settings tmp.pending[0]
execute if score #stbk_diff macroengine.tmp matches 0 run data modify storage macroengine:settings tmp.found set value 1b
data remove storage macroengine:settings tmp.pending[0]
execute unless data storage macroengine:settings tmp{found:1b} run function macroengine:core/internal/api/settings/_block_has_loop
return 1
