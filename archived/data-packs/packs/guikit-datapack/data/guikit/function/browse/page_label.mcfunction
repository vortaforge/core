execute unless score #guikit.open vortaforge.gate matches 1 run return 0
execute if entity @s[type=minecraft:player] unless entity @s[tag=guikit.consented] unless score #guikit.gate.3 vortaforge.gate matches 0 run return 0
scoreboard players set #show guikit.tmp 1
scoreboard players operation #show guikit.tmp += @s guikit.bpage
execute store result storage guikit:ctx page int 1 run scoreboard players get #show guikit.tmp
execute store result storage guikit:ctx count int 1 run scoreboard players get #vcount guikit.tmp
function guikit:browse/page_label_do with storage guikit:ctx
