# as interaction. Player who just clicked is tagged guikit.gclick.
execute unless score #guikit.open vortaforge.gate matches 1 run return 0
execute if entity @s[type=minecraft:player] unless entity @s[tag=guikit.consented] unless score #guikit.gate.3 vortaforge.gate matches 0 run return 0
scoreboard players set #gmatch guikit.tmp 0
execute if data entity @s interaction on target if entity @s[tag=guikit.gclick] run scoreboard players set #gmatch guikit.tmp 1
execute if data entity @s attack on attacker if entity @s[tag=guikit.gclick] run scoreboard players set #gmatch guikit.tmp 1
execute if score #gmatch guikit.tmp matches 1.. run function guikit:internal/guard/apply
