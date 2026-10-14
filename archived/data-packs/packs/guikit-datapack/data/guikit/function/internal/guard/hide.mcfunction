# as cart. Remove this owner's guard so they can right-click the cart.
execute unless score #guikit.open vortaforge.gate matches 1 run return 0
execute if entity @s[type=minecraft:player] unless entity @s[tag=guikit.consented] unless score #guikit.gate.3 vortaforge.gate matches 0 run return 0
execute as @e[type=minecraft:interaction,tag=guikit.guard] if score @s guikit.uid = #guid guikit.tmp run kill @s
