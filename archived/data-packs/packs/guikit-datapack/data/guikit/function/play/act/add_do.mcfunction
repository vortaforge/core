# macro: $(pid) $(key) $(delta) $(max)
execute unless score #guikit.open vortaforge.gate matches 1 run return 0
execute if entity @s[type=minecraft:player] unless entity @s[tag=guikit.consented] unless score #guikit.gate.3 vortaforge.gate matches 0 run return 0
$scoreboard players add p$(pid)_$(key) guikit.var $(delta)
$execute if score p$(pid)_$(key) guikit.var matches $(max).. run scoreboard players set p$(pid)_$(key) guikit.var $(max)
$tellraw @s [{"text":"[GUI] ","color":"gray"},{"score":{"name":"p$(pid)_$(key)","objective":"guikit.var"},"color":"aqua"}]
