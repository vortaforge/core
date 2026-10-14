execute unless score #guikit.open vortaforge.gate matches 1 run return 0
execute if entity @s[type=minecraft:player] unless entity @s[tag=guikit.consented] unless score #guikit.gate.3 vortaforge.gate matches 0 run return 0
execute store result storage guikit:ctx pid int 1 run scoreboard players get @s guikit.pid
function guikit:editor/save_state_do with storage guikit:ctx
