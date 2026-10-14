# guikit :: internal/click_handle   as player, ONLY called when the GUI-item count is >= 1
execute unless score #guikit.open vortaforge.gate matches 1 run return 0
execute if entity @s[type=minecraft:player] unless entity @s[tag=guikit.consented] unless score #guikit.gate.3 vortaforge.gate matches 0 run return 0
function #guikit:probe

# remove only widget items, and only if any are still there (a handler may have closed the menu,
# in which case api/close already cleared them)
function guikit:internal/safe_clear

# left-click emptied a cart slot -> redraw. Skipped when the handler closed the menu
# (api/close resets guikit.uid), otherwise fill would run against a stale #uid.
execute if score @s guikit.uid matches 1.. run scoreboard players set @s guikit.dirty 1
