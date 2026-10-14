# guikit :: widget/cooldown_start   as player   storage guikit:in {ticks:N}
# Sets guikit.cd if free. Result: 1 = allowed (cooldown now running), 0 = still cooling down.
execute unless score #guikit.open vortaforge.gate matches 1 run return 0
execute if entity @s[type=minecraft:player] unless entity @s[tag=guikit.consented] unless score #guikit.gate.3 vortaforge.gate matches 0 run return 0
execute if score @s guikit.cd matches 1.. run return 0
function guikit:internal/cooldown/set with storage guikit:in