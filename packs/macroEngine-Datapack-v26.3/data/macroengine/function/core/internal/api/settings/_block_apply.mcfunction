# macroengine:core/internal/api/settings/_block_apply [INTERNAL]
# blocklist.add / blocklist.remove / blocklist.reset / blocklist.clear.
# reset deletes the storage list so systems/cmd_gate/blocklist reseeds
# the shipped defaults; clear writes an empty-but-present list, which
# the seeder deliberately does not overwrite.

execute unless score #macroengine.open vortaforge.gate matches 1 run return 0
execute if entity @s[type=minecraft:player] unless entity @s[tag=macroengine.consented] unless score #macroengine.gate.3 vortaforge.gate matches 0 run return 0
data modify storage macroengine:settings tmp.handled set value 1b
data remove storage macroengine:settings tmp.sub
data modify storage macroengine:settings tmp.sub set string storage macroengine:settings tmp.key 10
execute if data storage macroengine:settings tmp{sub:"reset"} run function macroengine:core/internal/api/settings/_block_reset
execute if data storage macroengine:settings tmp{sub:"clear"} run function macroengine:core/internal/api/settings/_block_reset
execute if data storage macroengine:settings tmp{sub:"reset"} run return 1
execute if data storage macroengine:settings tmp{sub:"clear"} run return 1
execute if data storage macroengine:settings tmp{sub:"add"} run function macroengine:core/internal/api/settings/_block_root
execute if data storage macroengine:settings tmp{sub:"add"} run function macroengine:core/internal/api/settings/_block_add
execute if data storage macroengine:settings tmp{sub:"remove"} run function macroengine:core/internal/api/settings/_block_root
execute if data storage macroengine:settings tmp{sub:"remove"} run function macroengine:core/internal/api/settings/_block_remove
execute if data storage macroengine:settings tmp{sub:"add"} run return 1
execute if data storage macroengine:settings tmp{sub:"remove"} run return 1
function macroengine:core/internal/api/settings/_err
return 0
