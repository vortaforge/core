# ─────────────────────────────────────────────────────────────────
# macroengine:api/cmd/other/multi_cmd/utils/get_stats
# Mevcut istatistikleri macroengine:output'a kopyala
# ─────────────────────────────────────────────────────────────────

execute if data storage macroengine:engine modules{cmd:0b} run return 0
data modify storage macroengine:output stats set from storage macroengine:engine _mcmd_stats
