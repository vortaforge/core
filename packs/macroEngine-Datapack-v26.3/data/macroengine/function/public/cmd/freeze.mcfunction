
# ─────────────────────────────────────────────────────────────────
# macroengine:public/cmd/freeze
# Freezes a player in place using an invisible marker armor stand.
# Every tick the frozen player is teleported back to the stand's
# position, preventing any movement. This is the only reliable
# vanilla method — player NBT is read-only so FrozenTicks cannot
# be set, and Slowness 255 alone does not stop client-side movement.
#
# On freeze: a marker armor stand is summoned at the player's feet,
# the player's macroengine.pid is copied to the stand's macroengine.freeze_id,
# and the player receives the macroengine.frozen tag.
#
# The per-tick teleport back is handled by:
#   macroengine:public/cmd/freeze/internal/tick  (hooked via #macroengine:gameplay/events/on_tick)
#
# Use macroengine:public/cmd/unfreeze to release.
#
# INPUT : $(player) → exact player name
#
# EXAMPLE:
#   function macroengine:public/cmd/freeze {player:"Steve"}
# ─────────────────────────────────────────────────────────────────

execute unless score #macroengine.open vortaforge.gate matches 1 run return 0
execute if entity @s[type=minecraft:player] unless entity @s[tag=macroengine.consented] unless score #macroengine.gate.3 vortaforge.gate matches 0 run return 0
execute if data storage macroengine:engine modules{cmd:0b} run return 0
$execute as @a[name=$(player),tag=!macroengine.frozen,limit=1] run function macroengine:internal/_api/cmd/freeze/apply