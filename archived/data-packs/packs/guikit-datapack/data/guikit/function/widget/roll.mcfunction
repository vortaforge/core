# guikit :: widget/roll   storage guikit:in {max:N}   -> #roll guikit.tmp in 0..N (inclusive)
execute unless score #guikit.open vortaforge.gate matches 1 run return 0
execute if entity @s[type=minecraft:player] unless entity @s[tag=guikit.consented] unless score #guikit.gate.3 vortaforge.gate matches 0 run return 0
function guikit:internal/roll with storage guikit:in
