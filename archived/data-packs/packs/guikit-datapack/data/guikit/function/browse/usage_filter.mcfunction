execute unless score #guikit.open vortaforge.gate matches 1 run return 0
execute if entity @s[type=minecraft:player] unless entity @s[tag=guikit.consented] unless score #guikit.gate.3 vortaforge.gate matches 0 run return 0
tellraw @s [{"text":"[guikit] ","color":"red"},{"text":"1 cycles, 2 all, 3 chest, 4 hopper, 5 barrel, 6 ender, 7 trapped, 8 shulker, 9 copper.","color":"gray"}]
