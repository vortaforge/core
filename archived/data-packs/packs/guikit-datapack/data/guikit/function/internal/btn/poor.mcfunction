# guikit :: internal/btn/poor     as player     reads storage guikit:btn cur.poor
execute unless score #guikit.open vortaforge.gate matches 1 run return 0
execute if entity @s[type=minecraft:player] unless entity @s[tag=guikit.consented] unless score #guikit.gate.3 vortaforge.gate matches 0 run return 0
function guikit:internal/clear/in
data modify storage guikit:in msg set value "You can't afford that."
execute if data storage guikit:btn cur.poor run data modify storage guikit:in msg set from storage guikit:btn cur.poor
data modify storage guikit:in color set value "red"
function guikit:widget/say
