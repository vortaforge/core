# as guard. Kill it if no cart still carries this uid.
execute unless score #guikit.open vortaforge.gate matches 1 run return 0
execute if entity @s[type=minecraft:player] unless entity @s[tag=guikit.consented] unless score #guikit.gate.3 vortaforge.gate matches 0 run return 0
scoreboard players set #guid guikit.tmp 0
scoreboard players operation #guid guikit.tmp = @s guikit.uid
execute unless score #guid guikit.tmp matches 1.. run return run kill @s
scoreboard players set #gfound guikit.tmp 0
execute as @e[type=#guikit:container,tag=guikit.cart] if score @s guikit.uid = #guid guikit.tmp run scoreboard players set #gfound guikit.tmp 1
execute if score #gfound guikit.tmp matches 0 run kill @s
