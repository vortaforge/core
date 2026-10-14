# macro: $(id)     as player     (called by widget/button with storage guikit:w)
# Swaps guikit:w item for the definition's locked_item when its cond currently fails.
execute unless score #guikit.open vortaforge.gate matches 1 run return 0
execute if entity @s[type=minecraft:player] unless entity @s[tag=guikit.consented] unless score #guikit.gate.3 vortaforge.gate matches 0 run return 0
data remove storage guikit:btn cur
$data modify storage guikit:btn cur set from storage guikit:btn defs."$(id)"
execute unless data storage guikit:btn cur.cond unless data storage guikit:btn cur.cost run return 0
function guikit:internal/btn/gate
execute if score #cond guikit.tmp matches 1 run return 0
data modify storage guikit:w item set value "minecraft:barrier"
execute if data storage guikit:btn cur.locked_item run data modify storage guikit:w item set from storage guikit:btn cur.locked_item
