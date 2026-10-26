# ======================================================================================
# macroengine:internal/ext/rng/shuffle_step [INTERNAL]
# One Fisher-Yates round: swap element #macroengine.ext_shf_i with a random element 0..#ext_shf_i,
# then recurse with the next lower index until it reaches 0.
# ======================================================================================

execute unless score #macroengine.open vortaforge.gate matches 1 run return 0
execute if entity @s[type=minecraft:player] unless entity @s[tag=macroengine.consented] unless score #macroengine.gate.3 vortaforge.gate matches 0 run return 0
data modify storage macroengine:engine _ext_shf_arg set value {min:0}
execute store result storage macroengine:engine _ext_shf_arg.max int 1 run scoreboard players get #macroengine.ext_shf_i macroengine.tmp
function macroengine:modules/rng/int with storage macroengine:engine _ext_shf_arg
execute store result storage macroengine:engine _ext_shf_arg.j int 1 run data get storage macroengine:output result
execute store result storage macroengine:engine _ext_shf_arg.i int 1 run scoreboard players get #macroengine.ext_shf_i macroengine.tmp
function macroengine:internal/ext/rng/shuffle_swap with storage macroengine:engine _ext_shf_arg
scoreboard players remove #macroengine.ext_shf_i macroengine.tmp 1
execute if score #macroengine.ext_shf_i macroengine.tmp matches 1.. run function macroengine:internal/ext/rng/shuffle_step
