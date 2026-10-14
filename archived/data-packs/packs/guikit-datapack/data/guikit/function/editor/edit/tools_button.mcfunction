execute unless score #guikit.open vortaforge.gate matches 1 run return 0
execute if entity @s[type=minecraft:player] unless entity @s[tag=guikit.consented] unless score #guikit.gate.3 vortaforge.gate matches 0 run return 0
function guikit:internal/clear/w
data modify storage guikit:w slot set value 26
data modify storage guikit:w item set value "minecraft:knowledge_book"
data modify storage guikit:w id set value "edtools"
data modify storage guikit:w type set value "tool"
data modify storage guikit:w name set value {text:"Tools",color:"gold",italic:false}
data modify storage guikit:w lore set value [{text:"Pages, settings, preview",color:"gray",italic:false},{text:"Not part of the menu",color:"dark_gray",italic:false}]
function guikit:widget/draw
