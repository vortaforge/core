execute unless score #macroengine.open vortaforge.gate matches 1 run return 0
execute if entity @s[type=minecraft:player] unless entity @s[tag=macroengine.consented] unless score #macroengine.gate.3 vortaforge.gate matches 0 run return 0
execute if data storage macroengine:engine modules{cmd:0b} run return 0
data modify storage macroengine:output multiCommands.executed set value 0b

execute at @s store success storage macroengine:output multiCommands.executed byte 1 unless function macroengine:public/cmd/other/multi_cmd/advanced/run_with_options run return 0
