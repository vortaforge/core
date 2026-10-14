# as cart, at cart. Used when a non-owner managed to click the cart itself.
execute unless score #guikit.open vortaforge.gate matches 1 run return 0
execute if entity @s[type=minecraft:player] unless entity @s[tag=guikit.consented] unless score #guikit.gate.3 vortaforge.gate matches 0 run return 0
scoreboard players operation #guid guikit.tmp = @s guikit.uid
function guikit:internal/guard/show
