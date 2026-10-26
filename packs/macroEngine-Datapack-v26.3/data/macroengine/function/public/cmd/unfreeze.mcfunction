
# ─────────────────────────────────────────────────────────────────
# macroengine:public/cmd/unfreeze
# Releases a player previously frozen by macroengine:public/cmd/freeze.
#
# 1. Finds the frozen player's macroengine.pid.
# 2. Kills the anchor armor stand whose macroengine.freeze_id matches.
# 3. Removes the macroengine.frozen tag so the tick function stops
#    teleporting them.
# 4. Plays the unfreeze sound and notifies the player.
#
# INPUT : $(player) → exact player name
#
# EXAMPLE:
#   function macroengine:public/cmd/unfreeze {player:"Steve"}
# ─────────────────────────────────────────────────────────────────

execute unless score #macroengine.open vortaforge.gate matches 1 run return 0
execute if entity @s[type=minecraft:player] unless entity @s[tag=macroengine.consented] unless score #macroengine.gate.3 vortaforge.gate matches 0 run return 0
execute if data storage macroengine:engine modules{cmd:0b} run return 0
$execute as @a[name=$(player),tag=macroengine.frozen,limit=1] run function macroengine:internal/_api/cmd/freeze/remove