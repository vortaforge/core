# guikit :: internal/clear_mtr
# Clears the guikit:mtr scratch storage before a fresh defs lookup, so stale keys from a
# previous meter_draw / meter_probe call (obj, max, width, id, c, cur) can never leak into the
# next one. Same idea as internal/clear_in / internal/clear_w.
execute unless score #guikit.open vortaforge.gate matches 1 run return 0
execute if entity @s[type=minecraft:player] unless entity @s[tag=guikit.consented] unless score #guikit.gate.3 vortaforge.gate matches 0 run return 0
data remove storage guikit:mtr cur
data remove storage guikit:mtr obj
data remove storage guikit:mtr max
data remove storage guikit:mtr width
data remove storage guikit:mtr id
data remove storage guikit:mtr c
