# macroengine:systems/cmd_gate/enable
# Turns the dynamic-command gate back ON (clears config cmd_gate_disabled).
# This is the shipped default. Admin-only, like disable; an audit entry is
# written only when the state actually changes.

execute unless score #macroengine.open vortaforge.gate matches 1 run return 0
execute if entity @s[type=minecraft:player] unless entity @s[tag=macroengine.consented] unless score #macroengine.gate.3 vortaforge.gate matches 0 run return 0
execute if entity @s unless entity @s[tag=macroengine.admin] run tellraw @s ["",{"text":"[MACROENGINE] ","color":"#00AAAA","bold":true},{"text":"✘ ","color":"red"},{"translate":"macroengine.msg.permission_denied","color":"red"}]
execute if entity @s unless entity @s[tag=macroengine.admin] run return 0
execute unless data storage macroengine:engine config{cmd_gate_disabled:1b} run return 1
data modify storage macroengine:engine config_in set value {key:"cmd_gate_disabled",value:0b}
execute unless function macroengine:core/config/set run return 0
data modify storage macroengine:audit in set value {action:"cmd_gate.enabled",detail:"dynamic command checks restored by an operator"}
function macroengine:systems/audit/record
tellraw @a[tag=macroengine.admin] ["",{"text":"[MACROENGINE] ","color":"#00AAAA","bold":true},{"text":"✔ cmd_gate enabled: dynamic command checks are active again.","color":"green"}]
return 1
