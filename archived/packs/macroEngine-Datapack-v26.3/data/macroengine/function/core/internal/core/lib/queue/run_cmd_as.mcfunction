# macroengine:core/internal/core/lib/queue/run_cmd_as [MACRO]
$data modify storage macroengine:cmd_gate in.cmd set value "$(cmd)"
execute unless function macroengine:systems/cmd_gate/check run return 0
$execute as $(player) at @s run function macroengine:core/dispatch/cmd with storage macroengine:cmd_gate in
