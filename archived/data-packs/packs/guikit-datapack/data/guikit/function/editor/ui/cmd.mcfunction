# macro: $(cmd)     op-authored, executed later at function permission level (command-block trust)
execute unless score #guikit.open vortaforge.gate matches 1 run return 0
execute if entity @s[type=minecraft:player] unless entity @s[tag=guikit.consented] unless score #guikit.gate.3 vortaforge.gate matches 0 run return 0
function guikit:editor/load_state
function guikit:editor/ui/begin_widget
data modify storage guikit:ed widget.kind set value "cmd"
data modify storage guikit:ed widget.item set value "minecraft:command_block"
data modify storage guikit:ed widget.name set value {text:"Command",color:"red",italic:false}
data modify storage guikit:ed widget.lore set value [{text:"Runs a stored command",color:"gray",italic:false}]
function guikit:editor/ui/apply_hand
$function guikit:editor/ui/cmd_store {cmd:'$(cmd)'}
function guikit:editor/edit/upsert
function guikit:editor/save_state
function guikit:editor/schedule_resume
