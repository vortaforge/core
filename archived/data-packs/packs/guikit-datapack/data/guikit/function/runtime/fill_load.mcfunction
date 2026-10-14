# macro: $(uid)
execute unless score #guikit.open vortaforge.gate matches 1 run return 0
execute if entity @s[type=minecraft:player] unless entity @s[tag=guikit.consented] unless score #guikit.gate.3 vortaforge.gate matches 0 run return 0
$data modify storage guikit:sess cur set from storage guikit:sess bound.u$(uid)
execute unless data storage guikit:sess cur.mode run return 0
execute if data storage guikit:sess cur{mode:"home"} run return run function guikit:editor/home/fill
execute if data storage guikit:sess cur{mode:"edit"} run return run function guikit:editor/edit/fill
execute if data storage guikit:sess cur{mode:"pick"} run return run function guikit:editor/pick/fill
execute if data storage guikit:sess cur{mode:"browse"} run return run function guikit:browse/fill
execute if data storage guikit:sess cur{mode:"play"} run function guikit:play/fill
