execute unless score #guikit.open vortaforge.gate matches 1 run return 0
execute if entity @s[type=minecraft:player] unless entity @s[tag=guikit.consented] unless score #guikit.gate.3 vortaforge.gate matches 0 run return 0
function guikit:internal/clear/w
data modify storage guikit:w slot set value 13
data modify storage guikit:w item set value "minecraft:paper"
data modify storage guikit:w id set value "bempty"
data modify storage guikit:w type set value "decor"
data modify storage guikit:w name set value {text:"No published menus",color:"gray",italic:false}
data modify storage guikit:w lore set value [{text:"An operator can add some",color:"dark_gray",italic:false}]
execute if score @s guikit.bfilt matches 1.. run data modify storage guikit:w name set value {text:"Nothing in this filter",color:"gray",italic:false}
execute if score @s guikit.bfilt matches 1.. run data modify storage guikit:w lore set value [{text:"Hopper cycles the filter",color:"dark_gray",italic:false},{text:"/trigger guikit.filter set 2",color:"dark_gray",italic:false}]
function guikit:widget/draw
