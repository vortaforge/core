# macroengine:api/settings/apply
# Applies the settings book @s is holding, right now. The same thing
# happens automatically when the writable_book tick capture sees the book
# (core/internal/api/settings/_on_book, registered in the
# #macroengine:input/writable_book tag) - this function is the explicit
# path that does not wait for a slot change.
#
# Reads every page straight from the held item (the tick capture only
# guarantees page 0 in macroengine:input book.raw), parses "Key: Value"
# lines and applies them: gate.1..gate.5, gate.permit, cmd_gate,
# cfg.<any config key> (through the validated core/config/set) and
# blocklist.add/remove/reset/clear. Unknown or invalid lines change
# nothing and are collected in macroengine:settings result.errors.
# Admin-only; anything else is refused before a single line is read.

execute unless score #macroengine.open vortaforge.gate matches 1 run return 0
execute if entity @s[type=minecraft:player] unless entity @s[tag=macroengine.consented] unless score #macroengine.gate.3 vortaforge.gate matches 0 run return 0
execute unless entity @s[type=minecraft:player] run return 0
execute unless entity @s[tag=macroengine.admin] run tellraw @s ["",{"text":"[MACROENGINE] ","color":"#00AAAA","bold":true},{"text":"✘ ","color":"red"},{"translate":"macroengine.msg.permission_denied","color":"red"}]
execute unless entity @s[tag=macroengine.admin] run return 0
execute unless entity @s[nbt={SelectedItem:{components:{"minecraft:custom_data":{macroengine:{input:1b,inputItem:"writable_book",settings:1b}}}}}] run tellraw @s ["",{"text":"[MACROENGINE] ","color":"#00AAAA","bold":true},{"text":"✘ Hold the settings book (macroengine:api/settings/book) to apply it.","color":"red"}]
execute unless entity @s[nbt={SelectedItem:{components:{"minecraft:custom_data":{macroengine:{input:1b,inputItem:"writable_book",settings:1b}}}}}] run return 0

data modify storage macroengine:settings result set value {applied:0,rejected:0,errors:[]}
scoreboard players set #stbk_ok macroengine.tmp 0
scoreboard players set #stbk_err macroengine.tmp 0
data remove storage macroengine:settings tmp
data modify storage macroengine:settings tmp set value {chunks:[]}
data modify storage macroengine:settings tmp.pages set from entity @s SelectedItem.components."minecraft:writable_book_content".pages
execute unless data storage macroengine:settings tmp.pages[0] run data modify storage macroengine:settings tmp.pages set from entity @s SelectedItem.components."minecraft:written_book_content".pages
function macroengine:core/internal/api/settings/_page_loop
function macroengine:core/internal/api/settings/_chunk_loop

execute store result storage macroengine:settings result.applied int 1 run scoreboard players get #stbk_ok macroengine.tmp
execute store result storage macroengine:settings result.rejected int 1 run scoreboard players get #stbk_err macroengine.tmp
data modify storage macroengine:audit in set value {action:"settings.book_apply",detail:"settings book applied"}
function macroengine:systems/audit/record
tellraw @s ["",{"text":"[MACROENGINE] ","color":"#00AAAA","bold":true},{"text":"Settings: ","color":"gray"},{"score":{"name":"#stbk_ok","objective":"macroengine.tmp"},"color":"green"},{"text":" applied, ","color":"gray"},{"score":{"name":"#stbk_err","objective":"macroengine.tmp"},"color":"red"},{"text":" rejected.","color":"gray"}]
execute if score #stbk_err macroengine.tmp matches 1.. run tellraw @s ["",{"text":"[MACROENGINE] ","color":"#00AAAA","bold":true},{"text":"Rejected lines: ","color":"red"},{"plain":true,"storage":"macroengine:settings","nbt":"result.errors","interpret":false,"color":"yellow"}]
data remove storage macroengine:settings tmp
return run scoreboard players get #stbk_ok macroengine.tmp
