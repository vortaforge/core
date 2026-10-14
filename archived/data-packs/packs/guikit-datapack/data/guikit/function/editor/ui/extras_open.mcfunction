execute unless score #guikit.open vortaforge.gate matches 1 run return 0
execute if entity @s[type=minecraft:player] unless entity @s[tag=guikit.consented] unless score #guikit.gate.3 vortaforge.gate matches 0 run return 0
function guikit:editor/load_state
scoreboard players set #b guikit.tmp -1
execute store result score #b guikit.tmp run data get storage guikit:ed cur.slot
execute unless score #b guikit.tmp matches 0..26 run return run tellraw @s {"text":"[guikit] Pick a slot first.","color":"red"}
function guikit:editor/ui/load_widget
execute if score #ok guikit.tmp matches 0 run tellraw @s {"text":"[guikit] Place an action in this slot first.","color":"red"}
execute if score #ok guikit.tmp matches 0 run return run dialog show @s guikit:slot
execute if data storage guikit:ed widget{kind:"decor"} run tellraw @s {"text":"[guikit] Decoration is not clickable. Pick an action first.","color":"red"}
execute if data storage guikit:ed widget{kind:"decor"} run return run dialog show @s guikit:slot
function guikit:editor/ui/extras_tell
tag @s add guikit.xdialog
schedule function guikit:editor/ui/extras_show 2t
