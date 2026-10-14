# ─────────────────────────────────────────────────────────────────
# macroengine:api/cmd/other/multi_cmd/run_as
# Run queue as a specific entity
#
# INPUT (storage macroengine:input):
# selector → entity selector
# ─────────────────────────────────────────────────────────────────

execute unless score #macroengine.open vortaforge.gate matches 1 run return 0
execute if entity @s[type=minecraft:player] unless entity @s[tag=macroengine.consented] unless score #macroengine.gate.3 vortaforge.gate matches 0 run return 0
execute if data storage macroengine:engine modules{cmd:0b} run return 0
function macroengine:core/internal/api/cmd/other/multi_cmd/run_as_exec with storage macroengine:input
