# macro: $(pid)
execute unless score #guikit.open vortaforge.gate matches 1 run return 0
execute if entity @s[type=minecraft:player] unless entity @s[tag=guikit.consented] unless score #guikit.gate.3 vortaforge.gate matches 0 run return 0
data remove storage guikit:ed cur
$data modify storage guikit:ed cur set from storage guikit:ed p$(pid)
execute unless data storage guikit:ed cur run data modify storage guikit:ed cur set value {screen:"home",page:0,list_page:0,menu:"-",slot:-1}
