execute unless score #macroengine.open vortaforge.gate matches 1 run return 0
execute if entity @s[type=minecraft:player] unless entity @s[tag=macroengine.consented] unless score #macroengine.gate.3 vortaforge.gate matches 0 run return 0
execute if data storage macroengine:engine modules{math:0b} run return 0
$scoreboard players set $abs_v macroengine.tmp $(value)
# FIX (v26.3-r1): abs(-2147483648) is not representable in a 32-bit score and
# used to come back as -2147483648 (still negative). Saturate to INT_MAX.
execute if score $abs_v macroengine.tmp matches -2147483648 run scoreboard players set $abs_v macroengine.tmp 2147483647
scoreboard players set $abs_neg macroengine.tmp -1
execute if score $abs_v macroengine.tmp matches ..-1 run scoreboard players operation $abs_v macroengine.tmp *= $abs_neg macroengine.tmp
execute store result storage macroengine:output result int 1 run scoreboard players get $abs_v macroengine.tmp
