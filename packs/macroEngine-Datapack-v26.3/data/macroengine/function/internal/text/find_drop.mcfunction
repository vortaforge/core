# macroengine:internal/text/find_drop [INTERNAL] pops the oldest match #macroengine.tx_drop times
execute unless score #macroengine.open vortaforge.gate matches 1 run return 0
execute if entity @s[type=minecraft:player] unless entity @s[tag=macroengine.consented] unless score #macroengine.gate.3 vortaforge.gate matches 0 run return 0
data remove storage macroengine:text idx[0]
scoreboard players remove #macroengine.tx_drop macroengine.tmp 1
scoreboard players remove #macroengine.tx_hits macroengine.tmp 1
execute if score #macroengine.tx_drop macroengine.tmp matches 1.. run function macroengine:internal/text/find_drop
