# macro: $(own)
execute unless score #guikit.open vortaforge.gate matches 1 run return 0
execute if entity @s[type=minecraft:player] unless entity @s[tag=guikit.consented] unless score #guikit.gate.3 vortaforge.gate matches 0 run return 0
$execute if items entity @s weapon.offhand *[custom_data~{guikit:{w:1b}}] unless items entity @s weapon.offhand *[custom_data~{guikit:{own:$(own)}}] run function guikit:internal/guard/purge_hit {slot:"weapon.offhand"}
