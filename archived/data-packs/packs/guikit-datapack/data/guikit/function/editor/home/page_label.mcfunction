execute unless score #guikit.open vortaforge.gate matches 1 run return 0
execute if entity @s[type=minecraft:player] unless entity @s[tag=guikit.consented] unless score #guikit.gate.3 vortaforge.gate matches 0 run return 0
scoreboard players set #show guikit.tmp 1
execute store result score #lp guikit.tmp run data get storage guikit:ed cur.list_page
scoreboard players operation #show guikit.tmp += #lp guikit.tmp
execute store result storage guikit:ctx page int 1 run scoreboard players get #show guikit.tmp
function guikit:editor/home/page_label_do with storage guikit:ctx
