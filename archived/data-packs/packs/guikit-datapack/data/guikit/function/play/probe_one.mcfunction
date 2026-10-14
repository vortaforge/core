# macro: $(n) $(page) $(slot)
execute unless score #guikit.open vortaforge.gate matches 1 run return 0
execute if entity @s[type=minecraft:player] unless entity @s[tag=guikit.consented] unless score #guikit.gate.3 vortaforge.gate matches 0 run return 0
$execute store result score #hit guikit.tmp run clear @s *[custom_data~{guikit:{w:1b,id:"p$(n)_$(page)_$(slot)"}}] 0
execute if score #hit guikit.tmp matches 1.. run function guikit:play/act
