# guikit :: widget/pay_score   as player   storage guikit:in {obj:"coins", amount:50}
execute unless score #guikit.open vortaforge.gate matches 1 run return 0
execute if entity @s[type=minecraft:player] unless entity @s[tag=guikit.consented] unless score #guikit.gate.3 vortaforge.gate matches 0 run return 0
function guikit:internal/pay_score with storage guikit:in
return run scoreboard players get #paid guikit.tmp
