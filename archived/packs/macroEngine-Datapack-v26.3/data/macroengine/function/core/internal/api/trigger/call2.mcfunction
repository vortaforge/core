# macroengine:api/trigger/internal/call2 [MACRO]
# Gated by systems/cmd_gate/check (config dynamic_cmd + cmd.dynamic permission + blocklist).

$data modify storage macroengine:cmd_gate in.cmd set value "$(cmd)"
execute unless function macroengine:systems/cmd_gate/check run return 0
function macroengine:core/dispatch/cmd with storage macroengine:cmd_gate in
