# guikit :: play/last_store   macro: $(pid)
# Writes guikit:ctx last into the per-player slot guikit:mem last.m<pid>.
execute unless score #guikit.open vortaforge.gate matches 1 run return 0
execute if entity @s[type=minecraft:player] unless entity @s[tag=guikit.consented] unless score #guikit.gate.3 vortaforge.gate matches 0 run return 0
$data modify storage guikit:mem last.m$(pid) set from storage guikit:ctx last
