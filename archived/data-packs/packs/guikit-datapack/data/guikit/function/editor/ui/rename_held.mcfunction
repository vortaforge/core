execute unless score #guikit.open vortaforge.gate matches 1 run return 0
execute if entity @s[type=minecraft:player] unless entity @s[tag=guikit.consented] unless score #guikit.gate.3 vortaforge.gate matches 0 run return 0
execute store success score #named guikit.tmp run data modify storage guikit:ed widget.name set from entity @s SelectedItem.components."minecraft:custom_name"
execute if score #named guikit.tmp matches 0 run tellraw @s {"text":"[guikit] Hold an item you named in an anvil.","color":"red"}
