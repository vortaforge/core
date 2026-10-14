# macro: $(i)
execute unless score #guikit.open vortaforge.gate matches 1 run return 0
execute if entity @s[type=minecraft:player] unless entity @s[tag=guikit.consented] unless score #guikit.gate.3 vortaforge.gate matches 0 run return 0
scoreboard players set #lock guikit.tmp 0
$execute if score #limit guikit.tmp matches ..$(i) run scoreboard players set #lock guikit.tmp 1
execute if score #lock guikit.tmp matches 1.. run function guikit:editor/edit/placeholder_lock with storage guikit:work
execute if score #lock guikit.tmp matches 0 run function guikit:editor/edit/placeholder_open with storage guikit:work
