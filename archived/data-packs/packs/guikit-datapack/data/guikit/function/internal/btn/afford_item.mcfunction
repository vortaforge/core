# guikit :: internal/btn/afford_item     as player
# Reuses the item_count condition, which does not count the clicked widget item (see cond/t_item_count_do).
execute unless score #guikit.open vortaforge.gate matches 1 run return 0
execute if entity @s[type=minecraft:player] unless entity @s[tag=guikit.consented] unless score #guikit.gate.3 vortaforge.gate matches 0 run return 0
scoreboard players set #cond guikit.tmp 0
function guikit:internal/clear/cond
data modify storage guikit:cond item set from storage guikit:btn cur.cost.item
data modify storage guikit:cond min set from storage guikit:btn cur.cost.count
function guikit:cond/t_item_count_do with storage guikit:cond
function guikit:internal/clear/cond
