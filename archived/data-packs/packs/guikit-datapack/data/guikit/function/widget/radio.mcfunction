# guikit :: widget/radio   as player
# storage guikit:in {obj:"mode", value:2}
# Direct-assign generalization of widget/toggle for objectives with more than two states: each
# option in the group calls this with its own literal `value` (menu code decides which slot maps
# to which value, exactly like widget/toggle / widget/cycle -- no separate defs registry, unlike
# widget/button or widget/meter).
execute unless score #guikit.open vortaforge.gate matches 1 run return 0
execute if entity @s[type=minecraft:player] unless entity @s[tag=guikit.consented] unless score #guikit.gate.3 vortaforge.gate matches 0 run return 0
function guikit:internal/radio_set with storage guikit:in
scoreboard players set @s guikit.dirty 1
