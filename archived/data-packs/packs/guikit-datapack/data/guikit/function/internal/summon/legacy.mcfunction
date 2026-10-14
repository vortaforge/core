# macro: $(ctype)
# Not a registered container: treat the name as a vanilla entity id (chest_minecart,
# hopper_minecart, oak_chest_boat, ...). It still must be in #guikit:container to actually
# work -- open_fail catches anything that isn't (see that file's comment).
execute unless score #guikit.open vortaforge.gate matches 1 run return 0
execute if entity @s[type=minecraft:player] unless entity @s[tag=guikit.consented] unless score #guikit.gate.3 vortaforge.gate matches 0 run return 0
$data modify storage guikit:ctx cdef set value {entity:"$(ctype)", slots:27, pad:"minecraft:gray_stained_glass_pane"}
