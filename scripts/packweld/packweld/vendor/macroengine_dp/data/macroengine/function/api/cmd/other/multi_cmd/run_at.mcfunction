# ─────────────────────────────────────────────────────────────────
# macroengine:api/cmd/other/multi_cmd/run_at
# Run queue at a specific location
#
# INPUT (storage macroengine:input):
# selector → entity selector
# ─────────────────────────────────────────────────────────────────

execute if data storage macroengine:engine modules{cmd:0b} run return 0
function macroengine:core/internal/api/cmd/other/multi_cmd/run_at_exec with storage macroengine:input
