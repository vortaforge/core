# macroengine:internal/text/replace_loop [INTERNAL] emits "text before match" + replacement per match
execute unless score #macroengine.open vortaforge.gate matches 1 run return 0
execute if entity @s[type=minecraft:player] unless entity @s[tag=macroengine.consented] unless score #macroengine.gate.3 vortaforge.gate matches 0 run return 0
execute unless data storage macroengine:text idx[0] run return 0
execute store result score #macroengine.tx_k macroengine.tmp run data get storage macroengine:text idx[0]
scoreboard players operation #macroengine.tx_a macroengine.tmp = #macroengine.tx_pos macroengine.tmp
scoreboard players operation #macroengine.tx_b macroengine.tmp = #macroengine.tx_k macroengine.tmp
function macroengine:internal/text/_cut_ab
data modify storage macroengine:text pc append from storage macroengine:text win
data modify storage macroengine:text pc append from storage macroengine:text r.rep
scoreboard players operation #macroengine.tx_pos macroengine.tmp = #macroengine.tx_k macroengine.tmp
scoreboard players operation #macroengine.tx_pos macroengine.tmp += #macroengine.tx_nlen macroengine.tmp
data remove storage macroengine:text idx[0]
function macroengine:internal/text/replace_loop
