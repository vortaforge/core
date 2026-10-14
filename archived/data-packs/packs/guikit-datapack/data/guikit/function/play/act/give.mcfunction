execute unless score #guikit.open vortaforge.gate matches 1 run return 0
execute if entity @s[type=minecraft:player] unless entity @s[tag=guikit.consented] unless score #guikit.gate.3 vortaforge.gate matches 0 run return 0
scoreboard players set #paid guikit.tmp 1
execute if data storage guikit:work w.cost_item run function guikit:play/act/pay
execute if score #paid guikit.tmp matches 0 run scoreboard players set #acted guikit.tmp 0
execute if score #paid guikit.tmp matches 0 run return run tellraw @s {"text":"[GUI] You can't afford that.","color":"red"}
execute unless data storage guikit:work w.count run data modify storage guikit:work w.count set value 1
function guikit:play/act/give_do with storage guikit:work w
