# macroengine:api/settings/book
# Gives @s a settings book: the pack's normal input book
# (custom_data macroengine.input/inputItem, plus settings:1b), prefilled
# with the CURRENT gate and config values, one "Key: Value" per line.
# Edit the values in the book, close it, switch the hotbar slot away and
# back - the writable_book capture then applies it (or run
# macroengine:api/settings/apply while holding the book).
# Admin-only: the book can change gates, config and the cmd_gate blocklist,
# so it is never given to a non-admin and captures from non-admins are
# ignored. Full grammar: docs/settings_book.md.

execute unless score #macroengine.open vortaforge.gate matches 1 run return 0
execute if entity @s[type=minecraft:player] unless entity @s[tag=macroengine.consented] unless score #macroengine.gate.3 vortaforge.gate matches 0 run return 0
execute unless entity @s[type=minecraft:player] run return 0
execute unless entity @s[tag=macroengine.admin] run tellraw @s ["",{"text":"[MACROENGINE] ","color":"#00AAAA","bold":true},{"text":"✘ ","color":"red"},{"translate":"macroengine.msg.permission_denied","color":"red"}]
execute unless entity @s[tag=macroengine.admin] run return 0
function macroengine:core/config/ensure
function macroengine:core/internal/api/settings/_view
function macroengine:core/internal/api/settings/_give with storage macroengine:settings view
tellraw @s ["",{"text":"[MACROENGINE] ","color":"#00AAAA","bold":true},{"text":"Settings book given. Edit values, close the book, then switch slot away and back to apply.","color":"gray"}]
return 1
