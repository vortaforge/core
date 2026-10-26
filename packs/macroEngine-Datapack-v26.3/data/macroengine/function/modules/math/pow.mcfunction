execute unless score #macroengine.open vortaforge.gate matches 1 run return 0
execute if entity @s[type=minecraft:player] unless entity @s[tag=macroengine.consented] unless score #macroengine.gate.3 vortaforge.gate matches 0 run return 0
execute if data storage macroengine:engine modules{math:0b} run return 0
$scoreboard players set $pow_a macroengine.tmp $(a)
$scoreboard players set $pow_n macroengine.tmp $(n)
scoreboard players set $pow_r macroengine.tmp 1

execute if score $pow_n macroengine.tmp matches 0 run execute store result storage macroengine:output result int 1 run scoreboard players get $pow_r macroengine.tmp
execute if score $pow_n macroengine.tmp matches 0 run return 0

# FIX (v26.3-r1): a negative exponent used to fall straight through the loop
# guard and return 1 (as if n were 0). Integer pow has no fractional result,
# so a^-|n| is 0 for |a| > 1; report 0 and stop instead.
execute if score $pow_n macroengine.tmp matches ..-1 run data modify storage macroengine:output result set value 0
execute if score $pow_n macroengine.tmp matches ..-1 run return 0
function macroengine:internal/systems/math/pow_loop
execute store result storage macroengine:output result int 1 run scoreboard players get $pow_r macroengine.tmp
