# ─────────────────────────────────────────────────────────────────
# macroengine:api/cmd/other/multi_cmd/run_as
# Run queue as a specific entity
#
# INPUT (storage macroengine:input):
# selector → entity selector
# ─────────────────────────────────────────────────────────────────

execute if data storage macroengine:engine modules{cmd:0b} run return 0
function macroengine:core/internal/api/cmd/other/multi_cmd/run_as_exec with storage macroengine:input
