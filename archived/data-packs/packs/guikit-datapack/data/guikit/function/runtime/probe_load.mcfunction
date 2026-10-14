# macro: $(uid)
execute unless score #guikit.open vortaforge.gate matches 1 run return 0
execute if entity @s[type=minecraft:player] unless entity @s[tag=guikit.consented] unless score #guikit.gate.3 vortaforge.gate matches 0 run return 0
$data modify storage guikit:sess cur set from storage guikit:sess bound.u$(uid)
execute unless data storage guikit:sess cur.mode run return 0
execute if data storage guikit:sess cur{mode:"home"} run return run function guikit:editor/home/probe
execute if data storage guikit:sess cur{mode:"edit"} run return run function guikit:editor/edit/probe
execute if data storage guikit:sess cur{mode:"pick"} run return run function guikit:editor/pick/probe
execute if data storage guikit:sess cur{mode:"browse"} run return run function guikit:browse/probe
execute if data storage guikit:sess cur{mode:"play"} run function guikit:play/probe
