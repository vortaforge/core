# optional: if the player is holding an item, use it as the icon
execute unless score #guikit.open vortaforge.gate matches 1 run return 0
execute if entity @s[type=minecraft:player] unless entity @s[tag=guikit.consented] unless score #guikit.gate.3 vortaforge.gate matches 0 run return 0
execute if data entity @s SelectedItem.id run data modify storage guikit:ed widget.item set from entity @s SelectedItem.id
