# guikit :: internal/btn/pay_item     as player
# The clicked widget is still in the inventory here. Remove widget items first so pay_item can neither
# count it nor clear it instead of the player's real items (a button that costs its own item type).
execute unless score #guikit.open vortaforge.gate matches 1 run return 0
execute if entity @s[type=minecraft:player] unless entity @s[tag=guikit.consented] unless score #guikit.gate.3 vortaforge.gate matches 0 run return 0
function guikit:internal/safe_clear
function guikit:internal/pay_item with storage guikit:btn cur.cost
