# macroengine:core/internal/api/settings/_cmdgate_apply [INTERNAL]
# cmd_gate: 1/on means the gate checks are active; 0/off runs
# systems/cmd_gate/disable and stored commands execute unchecked. The
# enable/disable functions are themselves admin-only and audited, and
# are no-ops when the state already matches.

execute unless score #macroengine.open vortaforge.gate matches 1 run return 0
execute if entity @s[type=minecraft:player] unless entity @s[tag=macroengine.consented] unless score #macroengine.gate.3 vortaforge.gate matches 0 run return 0
data modify storage macroengine:settings tmp.handled set value 1b
function macroengine:core/internal/api/settings/_bool
execute unless data storage macroengine:settings tmp{bvalid:1b} run function macroengine:core/internal/api/settings/_err
execute unless data storage macroengine:settings tmp{bvalid:1b} run return 0
execute if data storage macroengine:settings tmp{bval:1b} run function macroengine:systems/cmd_gate/enable
execute if data storage macroengine:settings tmp{bval:0b} run function macroengine:systems/cmd_gate/disable
scoreboard players add #stbk_ok macroengine.tmp 1
return 1
