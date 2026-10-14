execute unless score #guikit.open vortaforge.gate matches 1 run return 0
execute if entity @s[type=minecraft:player] unless entity @s[tag=guikit.consented] unless score #guikit.gate.3 vortaforge.gate matches 0 run return 0
function guikit:internal/safe_clear
data modify storage guikit:work pay.item set from storage guikit:work w.cost_item
data modify storage guikit:work pay.count set from storage guikit:work w.cost_count
execute unless data storage guikit:work pay.count run data modify storage guikit:work pay.count set value 1
function guikit:internal/pay_item with storage guikit:work pay
