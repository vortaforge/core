# guikit :: cond/t_score    storage guikit:cond {obj, [min], [max]}
execute unless score #guikit.open vortaforge.gate matches 1 run return 0
execute if entity @s[type=minecraft:player] unless entity @s[tag=guikit.consented] unless score #guikit.gate.3 vortaforge.gate matches 0 run return 0
execute unless data storage guikit:cond obj run return 0
execute unless data storage guikit:cond min run data modify storage guikit:cond min set value -2147483648
execute unless data storage guikit:cond max run data modify storage guikit:cond max set value 2147483647
function guikit:cond/t_score_do with storage guikit:cond
