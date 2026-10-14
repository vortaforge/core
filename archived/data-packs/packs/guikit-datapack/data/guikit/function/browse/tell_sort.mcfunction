execute unless score #guikit.open vortaforge.gate matches 1 run return 0
execute if entity @s[type=minecraft:player] unless entity @s[tag=guikit.consented] unless score #guikit.gate.3 vortaforge.gate matches 0 run return 0
execute if score @s guikit.bsort matches 1 run tellraw @s [{"text":"[guikit] ","color":"gold"},{"text":"Newest first. ","color":"white"},{"text":"/trigger guikit.sort set 3","color":"aqua","click_event":{"action":"suggest_command","command":"/trigger guikit.sort set 3"}}]
execute unless score @s guikit.bsort matches 1 run tellraw @s [{"text":"[guikit] ","color":"gold"},{"text":"Oldest first. ","color":"white"},{"text":"/trigger guikit.sort set 2","color":"aqua","click_event":{"action":"suggest_command","command":"/trigger guikit.sort set 2"}}]
