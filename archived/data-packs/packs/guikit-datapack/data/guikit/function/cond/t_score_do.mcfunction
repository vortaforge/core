# macro: $(obj) $(min) $(max)
# Two open-ended ranges instead of one closed A..B range (see README "Validation status").
execute unless score #guikit.open vortaforge.gate matches 1 run return 0
execute if entity @s[type=minecraft:player] unless entity @s[tag=guikit.consented] unless score #guikit.gate.3 vortaforge.gate matches 0 run return 0
scoreboard players set #cond guikit.tmp 1
$execute unless score @s $(obj) matches $(min).. run scoreboard players set #cond guikit.tmp 0
$execute unless score @s $(obj) matches ..$(max) run scoreboard players set #cond guikit.tmp 0
