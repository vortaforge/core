# macroengine:api/cb/list
# ─────────────────────────────────────────────────────────────────
# Prints pending queue entries to the executor.
# Shows each queued command and its remaining ticks.
# ─────────────────────────────────────────────────────────────────


execute unless score #macroengine.open vortaforge.gate matches 1 run return 0
execute if entity @s[type=minecraft:player] unless entity @s[tag=macroengine.consented] unless score #macroengine.gate.3 vortaforge.gate matches 0 run return 0
execute if data storage macroengine:engine modules{cb:0b} run return 0
execute store result score #cb_queue_size macroengine.tmp run data get storage macroengine:engine cb_queue
execute if score #cb_queue_size macroengine.tmp matches 0 run tellraw @s [{"text":"[MACROENGINE/cb] ","color":"#00AAAA","bold":true},{"translate":"macroengine.msg.cb.queue_empty","fallback":"Queue is empty","color":"gray"}]
execute unless score #cb_queue_size macroengine.tmp matches 0 run tellraw @s [{"text":"[MACROENGINE/cb] ","color":"#00AAAA","bold":true},{"translate":"macroengine.msg.cb.queue_entries","fallback":"Queue (%s entries):","with":[{"score":{"name":"#cb_queue_size","objective":"macroengine.tmp"}}],"color":"#00AAAA","bold":true}]
execute unless score #cb_queue_size macroengine.tmp matches 0 run tellraw @s {"nbt":"cb_queue","plain":true ,"storage":"macroengine:engine","interpret":false}
