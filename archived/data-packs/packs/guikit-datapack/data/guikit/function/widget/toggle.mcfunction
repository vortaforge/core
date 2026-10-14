# guikit :: widget/toggle   as player   storage guikit:in {obj:"my_score"}
# Result: new state (0/1)
execute unless score #guikit.open vortaforge.gate matches 1 run return 0
execute if entity @s[type=minecraft:player] unless entity @s[tag=guikit.consented] unless score #guikit.gate.3 vortaforge.gate matches 0 run return 0
function guikit:internal/toggle with storage guikit:in
scoreboard players set @s guikit.dirty 1
