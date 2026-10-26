# Ward test (CI only). See cmd_gate_default_off.mcfunction.
# @max_ticks 40

# The operator kill-switch for the gate must default to OFF (gate active)
# and follow systems/cmd_gate/disable|enable through the config mirror.
function macroengine:gate/approve
await score #cmd_gate_disabled macroengine.tick_flags matches 0
function macroengine:systems/cmd_gate/disable
await score #cmd_gate_disabled macroengine.tick_flags matches 1
function macroengine:systems/cmd_gate/enable
await score #cmd_gate_disabled macroengine.tick_flags matches 0
