# ME - Universal World Clock Controller
# Usage: /function macroengine:public/cmd/time_of {clock:"macroengine:test", action:"set", value:"12000"}
execute unless score #macroengine.open vortaforge.gate matches 1 run return 0
execute if entity @s[type=minecraft:player] unless entity @s[tag=macroengine.consented] unless score #macroengine.gate.3 vortaforge.gate matches 0 run return 0
execute if data storage macroengine:engine modules{cmd:0b} run return 0
$time of $(clock) $(action) $(value)