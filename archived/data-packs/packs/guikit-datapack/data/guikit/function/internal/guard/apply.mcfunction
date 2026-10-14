# as interaction that this player just clicked
execute unless score #guikit.open vortaforge.gate matches 1 run return 0
execute if entity @s[type=minecraft:player] unless entity @s[tag=guikit.consented] unless score #guikit.gate.3 vortaforge.gate matches 0 run return 0
scoreboard players operation #guid guikit.tmp = @s guikit.uid
data remove entity @s interaction
data remove entity @s attack
execute as @a[tag=guikit.gclick,limit=1] run function guikit:internal/guard/from_player
