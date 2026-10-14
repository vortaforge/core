# guikit :: internal/btn/pay     as player     reads storage guikit:btn cur.cost
# Charges the cost through the existing helpers. Result in #paid guikit.tmp (1 = paid, 0 = not enough).
execute unless score #guikit.open vortaforge.gate matches 1 run return 0
execute if entity @s[type=minecraft:player] unless entity @s[tag=guikit.consented] unless score #guikit.gate.3 vortaforge.gate matches 0 run return 0
execute unless data storage guikit:btn cur.cost.count run data modify storage guikit:btn cur.cost.count set value 1
execute if data storage guikit:btn cur.cost.obj run function guikit:internal/pay_score with storage guikit:btn cur.cost
execute if data storage guikit:btn cur.cost.item run function guikit:internal/btn/pay_item
