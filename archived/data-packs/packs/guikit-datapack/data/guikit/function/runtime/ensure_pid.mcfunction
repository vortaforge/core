# guikit :: runtime/ensure_pid     stable per-player id, never reset on menu close
execute unless score #guikit.open vortaforge.gate matches 1 run return 0
execute if entity @s[type=minecraft:player] unless entity @s[tag=guikit.consented] unless score #guikit.gate.3 vortaforge.gate matches 0 run return 0
execute unless score @s guikit.pid matches 1.. run function guikit:runtime/assign_pid
