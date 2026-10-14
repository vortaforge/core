execute unless score #guikit.open vortaforge.gate matches 1 run return 0
execute if entity @s[type=minecraft:player] unless entity @s[tag=guikit.consented] unless score #guikit.gate.3 vortaforge.gate matches 0 run return 0
execute store result score #hit guikit.tmp run clear @s *[custom_data~{guikit:{w:1b,id:"hnew"}}] 0
execute if score #hit guikit.tmp matches 1.. run return run function guikit:editor/create
execute store result score #hit guikit.tmp run clear @s *[custom_data~{guikit:{w:1b,id:"hclose"}}] 0
execute if score #hit guikit.tmp matches 1.. run return run function guikit:api/close
execute store result score #hit guikit.tmp run clear @s *[custom_data~{guikit:{w:1b,id:"hhelp"}}] 0
execute if score #hit guikit.tmp matches 1.. run return run function guikit:editor/ui/help
execute store result score #hit guikit.tmp run clear @s *[custom_data~{guikit:{w:1b,id:"hprev"}}] 0
execute if score #hit guikit.tmp matches 1.. run return run function guikit:editor/home/page_prev
execute store result score #hit guikit.tmp run clear @s *[custom_data~{guikit:{w:1b,id:"hnext"}}] 0
execute if score #hit guikit.tmp matches 1.. run return run function guikit:editor/home/page_next
