# macroengine:internal/text/scan_deny_loop [INTERNAL]
execute unless score #macroengine.open vortaforge.gate matches 1 run return 0
execute if entity @s[type=minecraft:player] unless entity @s[tag=macroengine.consented] unless score #macroengine.gate.3 vortaforge.gate matches 0 run return 0
scoreboard players operation #macroengine.tx_a macroengine.tmp = #macroengine.tx_i macroengine.tmp
scoreboard players operation #macroengine.tx_b macroengine.tmp = #macroengine.tx_i macroengine.tmp
scoreboard players add #macroengine.tx_b macroengine.tmp 1
function macroengine:internal/text/_cut_ab
data modify storage macroengine:text mp set value {}
data modify storage macroengine:text mp.t set from storage macroengine:text tbl
data modify storage macroengine:text mp.c set from storage macroengine:text win
function macroengine:internal/text/_deny_probe with storage macroengine:text mp
execute if score #macroengine.tx_hit macroengine.tmp matches 1 run return 1
scoreboard players add #macroengine.tx_i macroengine.tmp 1
execute if score #macroengine.tx_i macroengine.tmp < #macroengine.tx_len macroengine.tmp run function macroengine:internal/text/scan_deny_loop
