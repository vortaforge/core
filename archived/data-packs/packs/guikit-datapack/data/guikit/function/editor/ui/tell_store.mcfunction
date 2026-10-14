# macro: $(msg) $(lore)
execute unless score #guikit.open vortaforge.gate matches 1 run return 0
execute if entity @s[type=minecraft:player] unless entity @s[tag=guikit.consented] unless score #guikit.gate.3 vortaforge.gate matches 0 run return 0
$data modify storage guikit:ed widget.msg set value "$(msg)"
$data modify storage guikit:ed lore_in set value "$(lore)"
data modify storage guikit:ed widget.lore set value [{text:"",color:"gray",italic:false}]
data modify storage guikit:ed widget.lore[0].text set from storage guikit:ed lore_in
data remove storage guikit:ed lore_in
