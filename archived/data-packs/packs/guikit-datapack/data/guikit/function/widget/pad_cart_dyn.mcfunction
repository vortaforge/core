# guikit :: widget/pad_cart_dyn     as cart (guikit.styled)
# Pad item and slot count come from the definition kept by owner uid (internal/cont_bind).
execute unless score #guikit.open vortaforge.gate matches 1 run return 0
execute if entity @s[type=minecraft:player] unless entity @s[tag=guikit.consented] unless score #guikit.gate.3 vortaforge.gate matches 0 run return 0
execute store result storage guikit:ctx uid int 1 run scoreboard players get @s guikit.uid
data remove storage guikit:ctx pad
function guikit:internal/pad/load with storage guikit:ctx
execute unless data storage guikit:ctx pad run return 0
scoreboard players operation #pi guikit.tmp = @s guikit.slots
function guikit:internal/pad/step
data remove storage guikit:ctx pad
data remove storage guikit:ctx uid
data remove storage guikit:ctx i
