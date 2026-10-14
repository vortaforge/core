execute unless score #guikit.open vortaforge.gate matches 1 run return 0
execute if entity @s[type=minecraft:player] unless entity @s[tag=guikit.consented] unless score #guikit.gate.3 vortaforge.gate matches 0 run return 0
execute unless score #skip guikit.tmp matches 1.. run return 0
execute unless data storage guikit:work list[0] run return 0
data remove storage guikit:work list[0]
scoreboard players remove #skip guikit.tmp 1
function guikit:editor/home/skip
