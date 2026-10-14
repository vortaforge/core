# Swap the icon for a barrier while this player's cooldown on this slot is running.
execute unless score #guikit.open vortaforge.gate matches 1 run return 0
execute if entity @s[type=minecraft:player] unless entity @s[tag=guikit.consented] unless score #guikit.gate.3 vortaforge.gate matches 0 run return 0
execute unless data storage guikit:work w.cd run return 0
function guikit:runtime/ensure_pid
execute store result storage guikit:work pid int 1 run scoreboard players get @s guikit.pid
execute store result storage guikit:work slot int 1 run data get storage guikit:work w.slot
function guikit:play/act/cd_check with storage guikit:work
execute unless score #left guikit.tmp matches 1.. run return 0
data modify storage guikit:w item set value "minecraft:barrier"
data modify storage guikit:w name set value {text:"Cooling down",color:"red",italic:false}
data modify storage guikit:w lore append value {text:"This button is cooling down",color:"red",italic:false}
