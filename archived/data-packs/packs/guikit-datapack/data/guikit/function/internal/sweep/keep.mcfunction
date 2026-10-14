# guikit :: internal/sweep_keep   as player with an open menu
execute unless score #guikit.open vortaforge.gate matches 1 run return 0
execute if entity @s[type=minecraft:player] unless entity @s[tag=guikit.consented] unless score #guikit.gate.3 vortaforge.gate matches 0 run return 0
scoreboard players operation #uid guikit.tmp = @s guikit.uid
execute as @e[type=#guikit:container,tag=guikit.cart,tag=guikit.orphan] if score @s guikit.uid = #uid guikit.tmp run tag @s remove guikit.orphan
