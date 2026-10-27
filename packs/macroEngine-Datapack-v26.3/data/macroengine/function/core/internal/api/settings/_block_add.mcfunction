# macroengine:core/internal/api/settings/_block_add [INTERNAL]
# Appends tmp.root unless it is already listed, so re-applying an
# unchanged book never grows the list.

execute unless score #macroengine.open vortaforge.gate matches 1 run return 0
execute if entity @s[type=minecraft:player] unless entity @s[tag=macroengine.consented] unless score #macroengine.gate.3 vortaforge.gate matches 0 run return 0
execute unless data storage macroengine:settings tmp{rvalid:1b} run function macroengine:core/internal/api/settings/_err
execute unless data storage macroengine:settings tmp{rvalid:1b} run return 0
function macroengine:systems/cmd_gate/blocklist
data modify storage macroengine:settings tmp.pending set from storage macroengine:engine cmd_blocklist
data modify storage macroengine:settings tmp.found set value 0b
function macroengine:core/internal/api/settings/_block_has_loop
execute unless data storage macroengine:settings tmp{found:1b} run data modify storage macroengine:engine cmd_blocklist append from storage macroengine:settings tmp.root
scoreboard players add #stbk_ok macroengine.tmp 1
return 1
