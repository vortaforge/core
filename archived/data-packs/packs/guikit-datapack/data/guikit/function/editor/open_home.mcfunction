# guikit :: editor/open_home     as player, at player
execute unless score #guikit.open vortaforge.gate matches 1 run return 0
execute if entity @s[type=minecraft:player] unless entity @s[tag=guikit.consented] unless score #guikit.gate.3 vortaforge.gate matches 0 run return 0
function guikit:editor/save_state
data remove storage guikit:ed pending
data modify storage guikit:ed pending set value {mode:"home",menu:"-",alias:"editor"}
function guikit:internal/clear/in
data merge storage guikit:in {menu:"guikit:editor",timer:6000}
function guikit:api/open
data remove storage guikit:ed pending
execute unless score #ok guikit.const matches 1 run tellraw @s {"text":"[guikit] Editor failed to open.","color":"red"}
execute if score #ok guikit.const matches 1 run tellraw @s [{"text":"[guikit] ","color":"gray"},{"text":"Menu list. ","color":"white"},{"text":"Emerald","color":"green"},{"text":" = new. Players use ","color":"gray"},{"text":"/trigger guikit.open","color":"aqua"}]
