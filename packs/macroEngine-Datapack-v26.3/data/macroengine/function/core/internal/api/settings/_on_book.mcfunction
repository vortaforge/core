# macroengine:core/internal/api/settings/_on_book [INTERNAL]
# Listener in the #macroengine:input/writable_book tag: runs on every
# input-book capture, as the player who holds the book. It must stay
# silent for every book that is not the settings book and for every
# non-admin (this fires from a tick scan - no denial spam), so both checks
# return quietly. api/settings/apply repeats the checks with messages for
# the manual path.

execute unless score #macroengine.open vortaforge.gate matches 1 run return 0
execute if entity @s[type=minecraft:player] unless entity @s[tag=macroengine.consented] unless score #macroengine.gate.3 vortaforge.gate matches 0 run return 0
execute unless entity @s[tag=macroengine.admin] run return 0
execute unless entity @s[nbt={SelectedItem:{components:{"minecraft:custom_data":{macroengine:{input:1b,inputItem:"writable_book",settings:1b}}}}}] run return 0
execute if data storage macroengine:input book.scan{suspicious:1b} run tellraw @s ["",{"text":"[MACROENGINE] ","color":"#00AAAA","bold":true},{"text":"⚠ Settings book not auto-applied: prompt-injection pattern in the text. Inspect the book; if it is really yours, run macroengine:api/settings/apply yourself (docs/prompt_injection.md).","color":"red"}]
execute if data storage macroengine:input book.scan{suspicious:1b} run return 0
return run function macroengine:api/settings/apply
