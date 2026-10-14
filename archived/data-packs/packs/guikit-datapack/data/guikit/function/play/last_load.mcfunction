# guikit :: play/last_load   macro: $(pid)
# Reads the per-player slot guikit:mem last.m<pid> into guikit:ctx last.
# A missing slot (player never opened a menu) fails silently and leaves ctx last unset.
execute unless score #guikit.open vortaforge.gate matches 1 run return 0
execute if entity @s[type=minecraft:player] unless entity @s[tag=guikit.consented] unless score #guikit.gate.3 vortaforge.gate matches 0 run return 0
$data modify storage guikit:ctx last set from storage guikit:mem last.m$(pid)
