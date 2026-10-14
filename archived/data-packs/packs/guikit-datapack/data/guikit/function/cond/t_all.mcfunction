# guikit :: cond/t_all     storage guikit:cond {type:"all", of:[{...}, ...], [not]}
# Passes when EVERY element passes (empty list = passes). See cond/comp_run.
execute unless score #guikit.open vortaforge.gate matches 1 run return 0
execute if entity @s[type=minecraft:player] unless entity @s[tag=guikit.consented] unless score #guikit.gate.3 vortaforge.gate matches 0 run return 0
scoreboard players set #cmode guikit.tmp 0
scoreboard players set #cacc guikit.tmp 1
return run function guikit:cond/comp_run
