# guikit :: widget/pay_item   as player   storage guikit:in {item:"minecraft:diamond", count:3}
# Result: 1 paid / 0 not enough
execute unless score #guikit.open vortaforge.gate matches 1 run return 0
execute if entity @s[type=minecraft:player] unless entity @s[tag=guikit.consented] unless score #guikit.gate.3 vortaforge.gate matches 0 run return 0
function guikit:internal/pay_item with storage guikit:in
return run scoreboard players get #paid guikit.tmp
