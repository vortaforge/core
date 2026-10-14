# guikit :: runtime/probe     #guikit:probe
execute unless score #guikit.open vortaforge.gate matches 1 run return 0
execute if entity @s[type=minecraft:player] unless entity @s[tag=guikit.consented] unless score #guikit.gate.3 vortaforge.gate matches 0 run return 0
execute unless score @s guikit.uid matches 1.. run return 0
execute store result storage guikit:ctx uid int 1 run scoreboard players get @s guikit.uid
function guikit:runtime/probe_load with storage guikit:ctx
