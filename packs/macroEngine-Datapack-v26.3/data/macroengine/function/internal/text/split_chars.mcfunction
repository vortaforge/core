# macroengine:internal/text/split_chars [INTERNAL] one entry per character
execute unless score #macroengine.open vortaforge.gate matches 1 run return 0
execute if entity @s[type=minecraft:player] unless entity @s[tag=macroengine.consented] unless score #macroengine.gate.3 vortaforge.gate matches 0 run return 0
scoreboard players operation #macroengine.tx_a macroengine.tmp = #macroengine.tx_i macroengine.tmp
scoreboard players operation #macroengine.tx_b macroengine.tmp = #macroengine.tx_i macroengine.tmp
scoreboard players add #macroengine.tx_b macroengine.tmp 1
function macroengine:internal/text/_cut_ab
data modify storage macroengine:text out append from storage macroengine:text win
scoreboard players add #macroengine.tx_i macroengine.tmp 1
execute if score #macroengine.tx_i macroengine.tmp < #macroengine.tx_len macroengine.tmp run function macroengine:internal/text/split_chars
