execute unless score #guikit.open vortaforge.gate matches 1 run return 0
execute if entity @s[type=minecraft:player] unless entity @s[tag=guikit.consented] unless score #guikit.gate.3 vortaforge.gate matches 0 run return 0
execute unless data storage guikit:work w.url run scoreboard players set #acted guikit.tmp 0
execute unless data storage guikit:work w.url run return run tellraw @s {"text":"[GUI] This button has no link.","color":"red"}
function guikit:internal/btn/url with storage guikit:work w
function guikit:api/close
