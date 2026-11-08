# macroengine:core/internal/api/cmd/other/multi_cmd/exec [MACRO]
$data modify storage macroengine:cmd_gate in.cmd set value "$(current_cmd)"
execute unless function macroengine:systems/cmd_gate/check run return 0
$execute run $(current_cmd)
