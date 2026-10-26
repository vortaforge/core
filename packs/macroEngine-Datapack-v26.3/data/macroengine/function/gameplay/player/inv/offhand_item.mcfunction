# ─────────────────────────────────────────────────────────────────
# macroengine:gameplay/player/inv/offhand_item
# Runs a command/function for each player in @a whose offhand
# matches the given item id and custom data.
# Mirrors the pattern of macroengine:gameplay/player/inv/selected_item (mainhand).
#
# INPUT : $(item)       → item id (e.g. "minecraft:shield")
#         $(custom_data) → custom_data compound to match (e.g. "{my_tag:1b}")
#         $(invoke)     → command to run as the matching player
#
# EXAMPLE:
# function macroengine:gameplay/player/inv/offhand_item {item:"minecraft:shield",custom_data:"{my_tag:1b}",invoke:"function mypack:on_shield"}
# ─────────────────────────────────────────────────────────────────

execute unless score #macroengine.open vortaforge.gate matches 1 run return 0
execute if entity @s[type=minecraft:player] unless entity @s[tag=macroengine.consented] unless score #macroengine.gate.3 vortaforge.gate matches 0 run return 0
$execute as @a[name=$(player),limit=1] at @s if items entity @s weapon.offhand $(item)[minecraft:custom_data=$(custom_data)] run $(invoke)
