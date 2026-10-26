# macroengine:internal/text/_cut_ab
# win = substring [#macroengine.tx_a, #macroengine.tx_b) of storage macroengine:text s. An empty range yields "" directly.
execute unless score #macroengine.open vortaforge.gate matches 1 run return 0
execute if entity @s[type=minecraft:player] unless entity @s[tag=macroengine.consented] unless score #macroengine.gate.3 vortaforge.gate matches 0 run return 0
execute if score #macroengine.tx_a macroengine.tmp = #macroengine.tx_b macroengine.tmp run data modify storage macroengine:text win set value ""
execute if score #macroengine.tx_a macroengine.tmp = #macroengine.tx_b macroengine.tmp run return 1
execute store result storage macroengine:text arg.a int 1 run scoreboard players get #macroengine.tx_a macroengine.tmp
execute store result storage macroengine:text arg.b int 1 run scoreboard players get #macroengine.tx_b macroengine.tmp
function macroengine:internal/text/_cut with storage macroengine:text arg
return 1
