# macro: $(i)
execute unless score #guikit.open vortaforge.gate matches 1 run return 0
execute if entity @s[type=minecraft:player] unless entity @s[tag=guikit.consented] unless score #guikit.gate.3 vortaforge.gate matches 0 run return 0
function guikit:internal/clear/w
$data modify storage guikit:w slot set value $(i)
data modify storage guikit:w item set value "minecraft:light_gray_stained_glass_pane"
data modify storage guikit:w type set value "edit"
$data modify storage guikit:w id set value "eds$(i)"
$data modify storage guikit:w name set value {text:"Slot $(i)",color:"dark_gray",italic:false}
data modify storage guikit:w lore set value [{text:"Hold an item, then click",color:"gray",italic:false}]
function guikit:widget/draw
