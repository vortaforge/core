execute unless score #macroengine.open vortaforge.gate matches 1 run return 0
execute if entity @s[type=minecraft:player] unless entity @s[tag=macroengine.consented] unless score #macroengine.gate.3 vortaforge.gate matches 0 run return 0
execute if data storage macroengine:engine modules{math:0b} run return 0
$scoreboard players set $mod_v macroengine.tmp $(value)
$scoreboard players set $mod_d macroengine.tmp $(divisor)

# FIX (v26.3-r1): a negative divisor used to be caught by "matches ..0" and
# reported as a division by zero (mod(7,-3) returned 0 instead of 1). Use the
# absolute value of the divisor, which is what the positive-remainder rule
# below already assumes. INT_MIN has no positive counterpart, so fold it.
execute if score $mod_d macroengine.tmp matches -2147483648 run scoreboard players set $mod_d macroengine.tmp 2147483647
execute if score $mod_d macroengine.tmp matches ..-1 run scoreboard players set $mod_neg macroengine.tmp -1
execute if score $mod_d macroengine.tmp matches ..-1 run scoreboard players operation $mod_d macroengine.tmp *= $mod_neg macroengine.tmp
execute if score $mod_d macroengine.tmp matches 0 run data modify storage macroengine:output result set value 0
execute if score $mod_d macroengine.tmp matches 0 run return 0

scoreboard players operation $mod_v macroengine.tmp %= $mod_d macroengine.tmp

execute if score $mod_v macroengine.tmp matches ..-1 run scoreboard players operation $mod_v macroengine.tmp += $mod_d macroengine.tmp

execute store result storage macroengine:output result int 1 run scoreboard players get $mod_v macroengine.tmp
