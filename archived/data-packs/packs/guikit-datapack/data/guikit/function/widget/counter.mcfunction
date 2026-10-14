# guikit :: widget/counter   as player
# storage guikit:in {obj:"score", delta:1, min:0, max:64, wrap:0b}
# wrap:0b -> clamp to [min,max]      wrap:1b -> roll over (min<->max)
execute unless score #guikit.open vortaforge.gate matches 1 run return 0
execute if entity @s[type=minecraft:player] unless entity @s[tag=guikit.consented] unless score #guikit.gate.3 vortaforge.gate matches 0 run return 0
function guikit:internal/counter_step with storage guikit:in
scoreboard players set @s guikit.dirty 1
