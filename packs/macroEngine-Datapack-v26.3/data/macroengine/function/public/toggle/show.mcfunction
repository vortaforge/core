# macroengine:public/toggle/show
# Prints a clickable module enable/disable menu.
#
# Usage:  function macroengine:public/toggle/show
# Caller: macroengine.admin tag required
#
# Each button runs:
#   /function macroengine:public/toggle/<Module>/<State>
#   where <State> is "true" (enable) or "false" (disable).
#
# Supported modules: hook, interaction, perm, wand, geo, cb, block, container
#
# BACKPORT NOTE (1.21.2): the original (26.x) opened this as a native
# `dialog show` screen with a free-text "Module Name" field and a boolean
# toggle, submitted via minecraft:dynamic/run_command templating. The
# dialog system does not exist in 1.21.2 (added in 1.21.6, pack format 80),
# and free-text input has no chat-command equivalent. Reimplemented as a
# fixed clickable menu — one Enable/Disable button pair per known module —
# which is functionally equivalent since the module list is fixed anyway.

execute unless score #macroengine.open vortaforge.gate matches 1 run return 0
execute if entity @s[type=minecraft:player] unless entity @s[tag=macroengine.consented] unless score #macroengine.gate.3 vortaforge.gate matches 0 run return 0
execute unless entity @s[tag=macroengine.admin] run return 0

tellraw @s ["",{"text":"═══════ ","color":"dark_gray"},{"text":"macroEngine — Module Toggles","color":"aqua","bold":true},{"text":" ═══════","color":"dark_gray"}]
tellraw @s ["",{"text":"hook       ","color":"white"},{"text":"[ON] ","color":"green","bold":true,"click_event":{"action":"run_command","command":"/function macroengine:public/toggle/hook/true"}},{"text":"[OFF]","color":"red","bold":true,"click_event":{"action":"run_command","command":"/function macroengine:public/toggle/hook/false"}}]
tellraw @s ["",{"text":"interaction","color":"white"},{"text":"[ON] ","color":"green","bold":true,"click_event":{"action":"run_command","command":"/function macroengine:public/toggle/interaction/true"}},{"text":"[OFF]","color":"red","bold":true,"click_event":{"action":"run_command","command":"/function macroengine:public/toggle/interaction/false"}}]
tellraw @s ["",{"text":"perm       ","color":"white"},{"text":"[ON] ","color":"green","bold":true,"click_event":{"action":"run_command","command":"/function macroengine:public/toggle/perm/true"}},{"text":"[OFF]","color":"red","bold":true,"click_event":{"action":"run_command","command":"/function macroengine:public/toggle/perm/false"}}]
tellraw @s ["",{"text":"wand       ","color":"white"},{"text":"[ON] ","color":"green","bold":true,"click_event":{"action":"run_command","command":"/function macroengine:public/toggle/wand/true"}},{"text":"[OFF]","color":"red","bold":true,"click_event":{"action":"run_command","command":"/function macroengine:public/toggle/wand/false"}}]
tellraw @s ["",{"text":"geo        ","color":"white"},{"text":"[ON] ","color":"green","bold":true,"click_event":{"action":"run_command","command":"/function macroengine:public/toggle/geo/true"}},{"text":"[OFF]","color":"red","bold":true,"click_event":{"action":"run_command","command":"/function macroengine:public/toggle/geo/false"}}]
tellraw @s ["",{"text":"cb         ","color":"white"},{"text":"[ON] ","color":"green","bold":true,"click_event":{"action":"run_command","command":"/function macroengine:public/toggle/cb/true"}},{"text":"[OFF]","color":"red","bold":true,"click_event":{"action":"run_command","command":"/function macroengine:public/toggle/cb/false"}}]
tellraw @s ["",{"text":"block      ","color":"white"},{"text":"[ON] ","color":"green","bold":true,"click_event":{"action":"run_command","command":"/function macroengine:public/toggle/block/true"}},{"text":"[OFF]","color":"red","bold":true,"click_event":{"action":"run_command","command":"/function macroengine:public/toggle/block/false"}}]
tellraw @s ["",{"text":"container  ","color":"white"},{"text":"[ON] ","color":"green","bold":true,"click_event":{"action":"run_command","command":"/function macroengine:public/toggle/container/true"}},{"text":"[OFF]","color":"red","bold":true,"click_event":{"action":"run_command","command":"/function macroengine:public/toggle/container/false"}}]
