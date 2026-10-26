# macroengine:internal/load/all — full init pipeline (no fork / rt_origin / confirm gates)

# forceload classic marker chunk (legacy features)
execute unless score #macroengine.open vortaforge.gate matches 1 run return 0
execute if entity @s[type=minecraft:player] unless entity @s[tag=macroengine.consented] unless score #macroengine.gate.3 vortaforge.gate matches 0 run return 0
# FIX (v26.3-r1): "forceload add -30000000 1600" used to run on every load and
# was never removed (cleanup only removes 0 0). On 26.3 that really does
# reserve chunk [-1875000, 100] for the life of the world. Removed.

# Load scoreboards, storages and other systems
function macroengine:internal/load/loader/scoreboards
function macroengine:internal/load/loader/storages
function macroengine:internal/load/loader/other

# Re-apply config after storages (storages may reset defaults)
function macroengine:config
function macroengine:engine/config/apply

# Run macroengine:internal/load/final function
function macroengine:internal/load/final
