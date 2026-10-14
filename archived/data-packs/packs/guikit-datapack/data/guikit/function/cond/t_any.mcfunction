# guikit :: cond/t_any     storage guikit:cond {type:"any", of:[{...}, ...], [not]}
# Passes when AT LEAST ONE element passes (empty list = fails). See cond/comp_run.
execute unless score #guikit.open vortaforge.gate matches 1 run return 0
execute if entity @s[type=minecraft:player] unless entity @s[tag=guikit.consented] unless score #guikit.gate.3 vortaforge.gate matches 0 run return 0
scoreboard players set #cmode guikit.tmp 1
scoreboard players set #cacc guikit.tmp 0
return run function guikit:cond/comp_run
