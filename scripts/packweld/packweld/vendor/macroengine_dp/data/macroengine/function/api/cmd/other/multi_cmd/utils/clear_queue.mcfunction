# ─────────────────────────────────────────────────────────────────
# macroengine:api/cmd/other/multi_cmd/utils/clear_queue
# Clear the queue
# ─────────────────────────────────────────────────────────────────

execute if data storage macroengine:engine modules{cmd:0b} run return 0
data remove storage macroengine:engine _mcmd_queue