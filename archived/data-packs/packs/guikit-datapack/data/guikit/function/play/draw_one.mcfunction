execute unless score #guikit.open vortaforge.gate matches 1 run return 0
execute if entity @s[type=minecraft:player] unless entity @s[tag=guikit.consented] unless score #guikit.gate.3 vortaforge.gate matches 0 run return 0
execute store result score #slot guikit.tmp run data get storage guikit:work w.slot
execute if score #slot guikit.tmp >= @s guikit.slots run return 0
execute if data storage guikit:work w{kind:"toggle"} run function guikit:play/visual_toggle
function guikit:internal/clear/w
data modify storage guikit:w slot set from storage guikit:work w.slot
data modify storage guikit:w item set from storage guikit:work w.item
execute unless data storage guikit:w item run data modify storage guikit:w item set value "minecraft:stone"
data modify storage guikit:w name set from storage guikit:work w.name
execute unless data storage guikit:w name run data modify storage guikit:w name set value {text:" ",italic:false}
data modify storage guikit:w lore set from storage guikit:work w.lore
execute unless data storage guikit:w lore run data modify storage guikit:w lore set value []
data modify storage guikit:w type set from storage guikit:work w.kind
execute unless data storage guikit:w type run data modify storage guikit:w type set value "widget"
execute store result storage guikit:work slot int 1 run scoreboard players get #slot guikit.tmp
function guikit:play/rule_lore
function guikit:play/cd_visual
function guikit:play/draw_id with storage guikit:work
function guikit:widget/draw
