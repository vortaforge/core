# macroengine:systems/cmd_gate/disable
# Turns the dynamic-command gate OFF (config cmd_gate_disabled). Stored
# command strings then macro-execute with no permission check, no length
# check and no blocklist - the pre-gate behaviour. This is an explicit,
# audited operator decision, not a default: only macroengine.admin players
# (or the console) can run it, and every actual change of state is written
# to the audit trail. Re-enable with systems/cmd_gate/enable.

execute unless score #macroengine.open vortaforge.gate matches 1 run return 0
execute if entity @s[type=minecraft:player] unless entity @s[tag=macroengine.consented] unless score #macroengine.gate.3 vortaforge.gate matches 0 run return 0
execute if entity @s unless entity @s[tag=macroengine.admin] run tellraw @s ["",{"text":"[MACROENGINE] ","color":"#00AAAA","bold":true},{"text":"✘ ","color":"red"},{"translate":"macroengine.msg.permission_denied","fallback":"Permission denied.","color":"red"}]
execute if entity @s unless entity @s[tag=macroengine.admin] run return 0
execute if data storage macroengine:engine config{cmd_gate_disabled:1b} run return 1
data modify storage macroengine:engine config_in set value {key:"cmd_gate_disabled",value:1b}
execute unless function macroengine:core/config/set run return 0
data modify storage macroengine:audit in set value {action:"cmd_gate.disabled",detail:"dynamic command checks bypassed by an operator"}
function macroengine:systems/audit/record
tellraw @a[tag=macroengine.admin] ["",{"text":"[MACROENGINE] ","color":"#00AAAA","bold":true},{"translate":"macroengine.msg.cmd_gate.disabled","fallback":"⚠ cmd_gate DISABLED: stored command strings now run unchecked. Re-enable with macroengine:systems/cmd_gate/enable","color":"red"}]
return 1
