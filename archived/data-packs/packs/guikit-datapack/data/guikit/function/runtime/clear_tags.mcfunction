# guikit :: runtime/clear_tags     #guikit:clear_tags — uid already copied to #uid and reset on the player
execute unless score #guikit.open vortaforge.gate matches 1 run return 0
execute if entity @s[type=minecraft:player] unless entity @s[tag=guikit.consented] unless score #guikit.gate.3 vortaforge.gate matches 0 run return 0
tag @s remove guikit.m.editor
tag @s remove guikit.m.browse
execute store result storage guikit:ctx uid int 1 run scoreboard players get #uid guikit.tmp
execute if score #uid guikit.tmp matches 1.. run function guikit:runtime/clear_alias with storage guikit:ctx
