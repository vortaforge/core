execute unless score #macroengine.open vortaforge.gate matches 1 run return 0
execute if entity @s[type=minecraft:player] unless entity @s[tag=macroengine.consented] unless score #macroengine.gate.3 vortaforge.gate matches 0 run return 0
execute if data storage macroengine:engine modules{math:0b} run return 0
$scoreboard players set $clamp_v macroengine.tmp $(value)
$scoreboard players set $clamp_lo macroengine.tmp $(min)
$scoreboard players set $clamp_hi macroengine.tmp $(max)

# FIX (v26.3-r1): with min > max the two clamps used to run in sequence and the
# value always ended at max (clamp(5,10,1) returned 1). Swap the bounds first.
scoreboard players set $clamp_swap macroengine.tmp 0
execute if score $clamp_lo macroengine.tmp > $clamp_hi macroengine.tmp run scoreboard players set $clamp_swap macroengine.tmp 1
execute if score $clamp_swap macroengine.tmp matches 1 run scoreboard players operation $clamp_t macroengine.tmp = $clamp_lo macroengine.tmp
execute if score $clamp_swap macroengine.tmp matches 1 run scoreboard players operation $clamp_lo macroengine.tmp = $clamp_hi macroengine.tmp
execute if score $clamp_swap macroengine.tmp matches 1 run scoreboard players operation $clamp_hi macroengine.tmp = $clamp_t macroengine.tmp
execute if score $clamp_v macroengine.tmp < $clamp_lo macroengine.tmp run scoreboard players operation $clamp_v macroengine.tmp = $clamp_lo macroengine.tmp
execute if score $clamp_v macroengine.tmp > $clamp_hi macroengine.tmp run scoreboard players operation $clamp_v macroengine.tmp = $clamp_hi macroengine.tmp

execute store result storage macroengine:output result int 1 run scoreboard players get $clamp_v macroengine.tmp
