# macroengine:core/internal/api/settings/_gate_apply [INTERNAL]
# gate.1 .. gate.5: forwards to the existing gate/set toggles so score
# names and gate/refresh stay owned by gate/*, nowhere else.

execute unless score #macroengine.open vortaforge.gate matches 1 run return 0
execute if entity @s[type=minecraft:player] unless entity @s[tag=macroengine.consented] unless score #macroengine.gate.3 vortaforge.gate matches 0 run return 0
data modify storage macroengine:settings tmp.handled set value 1b
function macroengine:core/internal/api/settings/_bool
execute unless data storage macroengine:settings tmp{bvalid:1b} run function macroengine:core/internal/api/settings/_err
execute unless data storage macroengine:settings tmp{bvalid:1b} run return 0
execute if data storage macroengine:settings tmp{key:"gate.1",bval:1b} run function macroengine:gate/set/1_on
execute if data storage macroengine:settings tmp{key:"gate.1",bval:0b} run function macroengine:gate/set/1_off
execute if data storage macroengine:settings tmp{key:"gate.2",bval:1b} run function macroengine:gate/set/2_on
execute if data storage macroengine:settings tmp{key:"gate.2",bval:0b} run function macroengine:gate/set/2_off
execute if data storage macroengine:settings tmp{key:"gate.3",bval:1b} run function macroengine:gate/set/3_on
execute if data storage macroengine:settings tmp{key:"gate.3",bval:0b} run function macroengine:gate/set/3_off
execute if data storage macroengine:settings tmp{key:"gate.4",bval:1b} run function macroengine:gate/set/4_on
execute if data storage macroengine:settings tmp{key:"gate.4",bval:0b} run function macroengine:gate/set/4_off
execute if data storage macroengine:settings tmp{key:"gate.5",bval:1b} run function macroengine:gate/set/5_on
execute if data storage macroengine:settings tmp{key:"gate.5",bval:0b} run function macroengine:gate/set/5_off
scoreboard players add #stbk_ok macroengine.tmp 1
return 1
