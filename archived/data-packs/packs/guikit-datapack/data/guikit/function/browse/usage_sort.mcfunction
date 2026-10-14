execute unless score #guikit.open vortaforge.gate matches 1 run return 0
execute if entity @s[type=minecraft:player] unless entity @s[tag=guikit.consented] unless score #guikit.gate.3 vortaforge.gate matches 0 run return 0
tellraw @s [{"text":"[guikit] ","color":"red"},{"text":"1 cycles, 2 oldest, 3 newest. ","color":"gray"},{"text":"/trigger guikit.sort","color":"aqua","click_event":{"action":"suggest_command","command":"/trigger guikit.sort"}}]
