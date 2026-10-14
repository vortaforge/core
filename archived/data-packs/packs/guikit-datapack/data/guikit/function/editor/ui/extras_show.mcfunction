execute unless score #guikit.open vortaforge.gate matches 1 run return 0
execute if entity @s[type=minecraft:player] unless entity @s[tag=guikit.consented] unless score #guikit.gate.3 vortaforge.gate matches 0 run return 0
execute as @a[tag=guikit.xdialog] run dialog show @s guikit:extras
tag @a remove guikit.xdialog
