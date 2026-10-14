# starts guikit:ed widget for cur.slot. Caller fills kind / item / name / lore / extras, then upsert.
execute unless score #guikit.open vortaforge.gate matches 1 run return 0
execute if entity @s[type=minecraft:player] unless entity @s[tag=guikit.consented] unless score #guikit.gate.3 vortaforge.gate matches 0 run return 0
data modify storage guikit:ed widget set value {kind:"decor",slot:0,item:"minecraft:stone",name:{text:"Item",italic:false},lore:[]}
execute store result storage guikit:ed widget.slot int 1 run data get storage guikit:ed cur.slot
