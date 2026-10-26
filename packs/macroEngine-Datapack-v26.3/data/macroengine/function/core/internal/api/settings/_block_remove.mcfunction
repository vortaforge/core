# macroengine:core/internal/api/settings/_block_remove [INTERNAL]
# Rebuilds the blocklist without tmp.root (all copies). Removing a root
# that is not listed is a successful no-op.

execute unless score #macroengine.open vortaforge.gate matches 1 run return 0
execute if entity @s[type=minecraft:player] unless entity @s[tag=macroengine.consented] unless score #macroengine.gate.3 vortaforge.gate matches 0 run return 0
execute unless data storage macroengine:settings tmp{rvalid:1b} run function macroengine:core/internal/api/settings/_err
execute unless data storage macroengine:settings tmp{rvalid:1b} run return 0
function macroengine:systems/cmd_gate/blocklist
data modify storage macroengine:settings tmp.pending set from storage macroengine:engine cmd_blocklist
data modify storage macroengine:settings tmp.kept set value []
function macroengine:core/internal/api/settings/_block_remove_loop
data modify storage macroengine:engine cmd_blocklist set from storage macroengine:settings tmp.kept
scoreboard players add #stbk_ok macroengine.tmp 1
return 1
