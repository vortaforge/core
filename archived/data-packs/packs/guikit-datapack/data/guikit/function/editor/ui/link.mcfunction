# macro: $(url)
execute unless score #guikit.open vortaforge.gate matches 1 run return 0
execute if entity @s[type=minecraft:player] unless entity @s[tag=guikit.consented] unless score #guikit.gate.3 vortaforge.gate matches 0 run return 0
function guikit:editor/load_state
function guikit:editor/ui/begin_widget
data modify storage guikit:ed widget.kind set value "link"
data modify storage guikit:ed widget.item set value "minecraft:paper"
data modify storage guikit:ed widget.name set value {text:"Link",color:"aqua",italic:false}
data modify storage guikit:ed widget.lore set value [{text:"Click to open",color:"gray",italic:false}]
function guikit:editor/ui/apply_hand
$function guikit:editor/ui/link_store {url:"$(url)"}
function guikit:editor/edit/upsert
function guikit:editor/save_state
function guikit:editor/schedule_resume
