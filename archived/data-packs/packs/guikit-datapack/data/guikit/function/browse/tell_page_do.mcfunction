# macro: $(page)
execute unless score #guikit.open vortaforge.gate matches 1 run return 0
execute if entity @s[type=minecraft:player] unless entity @s[tag=guikit.consented] unless score #guikit.gate.3 vortaforge.gate matches 0 run return 0
$tellraw @s [{"text":"[guikit] ","color":"gold"},{"text":"Page $(page). ","color":"white"},{"text":"/trigger guikit.goto set $(page)","color":"aqua","click_event":{"action":"suggest_command","command":"/trigger guikit.goto set $(page)"}}]
