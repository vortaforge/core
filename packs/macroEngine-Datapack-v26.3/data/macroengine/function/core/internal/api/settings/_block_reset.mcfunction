# macroengine:core/internal/api/settings/_block_reset [INTERNAL]
# Shared body for blocklist.reset and blocklist.clear. The value is a
# boolean confirmation: 1 acts, 0 is an explicit no-op (the prefilled
# book only shows these lines as comments, so reaching here at all means
# the operator wrote the line deliberately).

execute unless score #macroengine.open vortaforge.gate matches 1 run return 0
execute if entity @s[type=minecraft:player] unless entity @s[tag=macroengine.consented] unless score #macroengine.gate.3 vortaforge.gate matches 0 run return 0
function macroengine:core/internal/api/settings/_bool
execute unless data storage macroengine:settings tmp{bvalid:1b} run function macroengine:core/internal/api/settings/_err
execute unless data storage macroengine:settings tmp{bvalid:1b} run return 0
execute if data storage macroengine:settings tmp{sub:"reset",bval:1b} run data remove storage macroengine:engine cmd_blocklist
execute if data storage macroengine:settings tmp{sub:"reset",bval:1b} run function macroengine:systems/cmd_gate/blocklist
execute if data storage macroengine:settings tmp{sub:"clear",bval:1b} run data modify storage macroengine:engine cmd_blocklist set value []
scoreboard players add #stbk_ok macroengine.tmp 1
return 1
