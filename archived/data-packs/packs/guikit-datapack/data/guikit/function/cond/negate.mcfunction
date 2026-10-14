# guikit :: cond/negate    flips #cond guikit.tmp (0 <-> 1)
execute unless score #guikit.open vortaforge.gate matches 1 run return 0
execute if entity @s[type=minecraft:player] unless entity @s[tag=guikit.consented] unless score #guikit.gate.3 vortaforge.gate matches 0 run return 0
execute store success score #cond guikit.tmp if score #cond guikit.tmp matches 0
