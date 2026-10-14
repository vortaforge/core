# guikit :: internal/clear_w
# Same idea for the widget scratch storage guikit:w (progress leaves obj/width/max/full/empty behind).
execute unless score #guikit.open vortaforge.gate matches 1 run return 0
execute if entity @s[type=minecraft:player] unless entity @s[tag=guikit.consented] unless score #guikit.gate.3 vortaforge.gate matches 0 run return 0
data remove storage guikit:w empty
data remove storage guikit:w full
data remove storage guikit:w id
data remove storage guikit:w item
data remove storage guikit:w lore
data remove storage guikit:w max
data remove storage guikit:w name
data remove storage guikit:w obj
data remove storage guikit:w slot
data remove storage guikit:w type
data remove storage guikit:w width
