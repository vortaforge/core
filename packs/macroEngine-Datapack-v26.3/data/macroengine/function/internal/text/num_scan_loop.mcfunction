# macroengine:internal/text/num_scan_loop [INTERNAL] every character except the decimal point must be a digit
execute unless score #macroengine.open vortaforge.gate matches 1 run return 0
execute if entity @s[type=minecraft:player] unless entity @s[tag=macroengine.consented] unless score #macroengine.gate.3 vortaforge.gate matches 0 run return 0
execute unless score #macroengine.tx_i macroengine.tmp < #macroengine.tx_len macroengine.tmp run return 1
execute if score #macroengine.tx_i macroengine.tmp = #macroengine.tx_dotpos macroengine.tmp run scoreboard players add #macroengine.tx_i macroengine.tmp 1
execute unless score #macroengine.tx_i macroengine.tmp < #macroengine.tx_len macroengine.tmp run return 1
scoreboard players operation #macroengine.tx_a macroengine.tmp = #macroengine.tx_i macroengine.tmp
scoreboard players operation #macroengine.tx_b macroengine.tmp = #macroengine.tx_i macroengine.tmp
scoreboard players add #macroengine.tx_b macroengine.tmp 1
function macroengine:internal/text/_cut_ab
data modify storage macroengine:text mp set value {}
data modify storage macroengine:text mp.c set from storage macroengine:text win
data modify storage macroengine:text isd set value 0b
function macroengine:internal/text/_digit_probe with storage macroengine:text mp
execute if data storage macroengine:text {isd:0b} run return 0
scoreboard players add #macroengine.tx_i macroengine.tmp 1
return run function macroengine:internal/text/num_scan_loop
