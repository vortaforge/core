# macroengine:internal/text/find_hit [INTERNAL] record a match at #macroengine.tx_i and skip past it
execute unless score #macroengine.open vortaforge.gate matches 1 run return 0
execute if entity @s[type=minecraft:player] unless entity @s[tag=macroengine.consented] unless score #macroengine.gate.3 vortaforge.gate matches 0 run return 0
data modify storage macroengine:text idx append value 0
execute store result storage macroengine:text idx[-1] int 1 run scoreboard players get #macroengine.tx_i macroengine.tmp
scoreboard players add #macroengine.tx_hits macroengine.tmp 1
scoreboard players operation #macroengine.tx_i macroengine.tmp += #macroengine.tx_nlen macroengine.tmp
