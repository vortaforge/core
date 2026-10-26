# macroengine:internal/_api/block/_validate_stage [INTERNAL]
# validate handler when registered, otherwise: the block must be a container. RETURN 1 allowed, 0 denied.
execute unless score #macroengine.open vortaforge.gate matches 1 run return 0
execute if entity @s[type=minecraft:player] unless entity @s[tag=macroengine.consented] unless score #macroengine.gate.3 vortaforge.gate matches 0 run return 0
data modify storage macroengine:block tmp.m.h set value "validate"
execute store result score #macroengine.bk_v macroengine.tmp run function macroengine:internal/_api/block/_call with storage macroengine:block tmp.m
execute if score #macroengine.bk_v macroengine.tmp matches 1.. run return 1
execute if score #macroengine.bk_v macroengine.tmp matches 0 run return 0
return run function macroengine:internal/_api/container/_exists with storage macroengine:container tmp.k
