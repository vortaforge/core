# macroengine:core/internal/api/settings/_dispatch [INTERNAL]
# Routes a parsed key to its applier. Fixed keys match as stored data;
# the cfg. and blocklist. families match on a sliced prefix, also as
# data. The key never selects a function dynamically.

execute unless score #macroengine.open vortaforge.gate matches 1 run return 0
execute if entity @s[type=minecraft:player] unless entity @s[tag=macroengine.consented] unless score #macroengine.gate.3 vortaforge.gate matches 0 run return 0
execute if data storage macroengine:settings tmp{key:"gate.1"} run function macroengine:core/internal/api/settings/_gate_apply
execute if data storage macroengine:settings tmp{key:"gate.2"} run function macroengine:core/internal/api/settings/_gate_apply
execute if data storage macroengine:settings tmp{key:"gate.3"} run function macroengine:core/internal/api/settings/_gate_apply
execute if data storage macroengine:settings tmp{key:"gate.4"} run function macroengine:core/internal/api/settings/_gate_apply
execute if data storage macroengine:settings tmp{key:"gate.5"} run function macroengine:core/internal/api/settings/_gate_apply
execute if data storage macroengine:settings tmp{key:"gate.permit"} run function macroengine:core/internal/api/settings/_permit_apply
execute if data storage macroengine:settings tmp{key:"cmd_gate"} run function macroengine:core/internal/api/settings/_cmdgate_apply
execute if data storage macroengine:settings tmp{handled:1b} run return 1
data remove storage macroengine:settings tmp.head
data modify storage macroengine:settings tmp.head set string storage macroengine:settings tmp.key 0 4
execute if data storage macroengine:settings tmp{head:"cfg."} run function macroengine:core/internal/api/settings/_cfg_apply
execute if data storage macroengine:settings tmp{handled:1b} run return 1
data remove storage macroengine:settings tmp.head
data modify storage macroengine:settings tmp.head set string storage macroengine:settings tmp.key 0 10
execute if data storage macroengine:settings tmp{head:"blocklist."} run function macroengine:core/internal/api/settings/_block_apply
return 1
