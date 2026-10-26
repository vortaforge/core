# macroengine:internal/text/find_loop [INTERNAL] one window comparison per call
execute unless score #macroengine.open vortaforge.gate matches 1 run return 0
execute if entity @s[type=minecraft:player] unless entity @s[tag=macroengine.consented] unless score #macroengine.gate.3 vortaforge.gate matches 0 run return 0
scoreboard players operation #macroengine.tx_a macroengine.tmp = #macroengine.tx_i macroengine.tmp
scoreboard players operation #macroengine.tx_b macroengine.tmp = #macroengine.tx_i macroengine.tmp
scoreboard players operation #macroengine.tx_b macroengine.tmp += #macroengine.tx_nlen macroengine.tmp
function macroengine:internal/text/_cut_ab
data modify storage macroengine:text cmp set from storage macroengine:text win
execute store success score #macroengine.tx_diff macroengine.tmp run data modify storage macroengine:text cmp set from storage macroengine:text needle
execute if score #macroengine.tx_diff macroengine.tmp matches 0 run function macroengine:internal/text/find_hit
execute if score #macroengine.tx_diff macroengine.tmp matches 1 run scoreboard players add #macroengine.tx_i macroengine.tmp 1
execute if score #macroengine.tx_cap macroengine.tmp matches 1.. if score #macroengine.tx_hits macroengine.tmp >= #macroengine.tx_cap macroengine.tmp run return 0
execute if score #macroengine.tx_i macroengine.tmp <= #macroengine.tx_last macroengine.tmp run function macroengine:internal/text/find_loop
