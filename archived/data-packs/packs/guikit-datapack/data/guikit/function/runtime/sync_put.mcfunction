# macro: $(id) $(n)
execute unless score #guikit.open vortaforge.gate matches 1 run return 0
execute if entity @s[type=minecraft:player] unless entity @s[tag=guikit.consented] unless score #guikit.gate.3 vortaforge.gate matches 0 run return 0
$data modify storage guikit:reg containers.gkc_$(n) set from storage guikit:work cdef
$data modify storage guikit:reg menus."guikit:m/$(id)" set value {alias:"gkm_$(n)",container:"gkc_$(n)"}
$execute as @a run tag @s remove guikit.m.gkm_$(n)
