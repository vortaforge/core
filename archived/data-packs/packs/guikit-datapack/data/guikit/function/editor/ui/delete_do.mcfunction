# macro: $(menu)
execute unless score #guikit.open vortaforge.gate matches 1 run return 0
execute if entity @s[type=minecraft:player] unless entity @s[tag=guikit.consented] unless score #guikit.gate.3 vortaforge.gate matches 0 run return 0
$data remove storage guikit:lib menus.$(menu)
$data remove storage guikit:reg menus."guikit:m/$(menu)"
# v5: forget any /trigger guikit.last pointers at the deleted menu
$data modify storage guikit:ctx gone set value "$(menu)"
scoreboard players set #mi guikit.tmp 1
execute store result score #mn guikit.tmp run scoreboard players get #next_pid guikit.const
execute if score #mn guikit.tmp matches 1.. run function guikit:play/last_sweep
data remove storage guikit:ctx gone
