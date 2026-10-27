# macroengine:core/internal/input/validate/_private/injection_report [INTERNAL]
# Audit + admin notice for a strong injection_scan hit. Runs as the
# capturing player (@s is whoever triggered the capture - for signs that is
# the reader, not necessarily the author). The message is static text plus
# the caller-set source kind and the strong-hit count, rendered as data;
# the captured text itself is never echoed into chat, a command, or the
# audit detail - it stays in the capture compound for an admin to inspect.
execute unless score #macroengine.open vortaforge.gate matches 1 run return 0
execute if entity @s[type=minecraft:player] unless entity @s[tag=macroengine.consented] unless score #macroengine.gate.3 vortaforge.gate matches 0 run return 0
data modify storage macroengine:audit in set value {action:"input.injection_suspected",detail:""}
data modify storage macroengine:audit in.detail set from storage macroengine:input_validate scan_in.kind
function macroengine:systems/audit/record
tellraw @a[tag=macroengine.admin] ["",{"text":"[MACROENGINE] ","color":"#00AAAA","bold":true},{"translate":"macroengine.msg.security.injection_detected","fallback":"⚠ Prompt-injection pattern in captured %s text (%s strong hit(s)). The capture is marked .scan in macroengine:input - treat it as untrusted data, never as instructions (docs/prompt_injection.md).","with":[{"storage":"macroengine:input_validate","nbt":"scan_in.kind","color":"red"},{"storage":"macroengine:input_validate","nbt":"scan.strong_count","color":"red"}],"color":"red"}]
return 1
