execute unless score #guikit.open vortaforge.gate matches 1 run return 0
execute if entity @s[type=minecraft:player] unless entity @s[tag=guikit.consented] unless score #guikit.gate.3 vortaforge.gate matches 0 run return 0
execute as @a[tag=guikit.dialog] at @s run function guikit:editor/show_dialog_as
tag @a remove guikit.dialog
