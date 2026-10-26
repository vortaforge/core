# macroengine:api/settings/status
# Prints the live gate / dynamic-command / blocklist state to @s, resolved
# from scores and storage at print time. Read-only counterpart of the
# settings book (api/settings/book), for checking what an apply changed.

execute unless score #macroengine.open vortaforge.gate matches 1 run return 0
execute if entity @s[type=minecraft:player] unless entity @s[tag=macroengine.consented] unless score #macroengine.gate.3 vortaforge.gate matches 0 run return 0
tellraw @s ["",{"text":"[MACROENGINE] ","color":"#00AAAA","bold":true},{"text":"━━━ Settings status ━━━━━━━━━━━━━━","color":"aqua"}]
tellraw @s ["",{"text":" gates 1-5: ","color":"gray"},{"score":{"name":"#macroengine.gate.1","objective":"vortaforge.gate"},"color":"white"},{"text":"/","color":"gray"},{"score":{"name":"#macroengine.gate.2","objective":"vortaforge.gate"},"color":"white"},{"text":"/","color":"gray"},{"score":{"name":"#macroengine.gate.3","objective":"vortaforge.gate"},"color":"white"},{"text":"/","color":"gray"},{"score":{"name":"#macroengine.gate.4","objective":"vortaforge.gate"},"color":"white"},{"text":"/","color":"gray"},{"score":{"name":"#macroengine.gate.5","objective":"vortaforge.gate"},"color":"white"},{"text":"  open=","color":"gray"},{"score":{"name":"#macroengine.open","objective":"vortaforge.gate"},"color":"white"},{"text":" permit=","color":"gray"},{"score":{"name":"#macroengine.permit","objective":"vortaforge.gate"},"color":"white"}]
tellraw @s ["",{"text":" dynamic_cmd=","color":"gray"},{"score":{"name":"#dynamic_cmd","objective":"macroengine.tick_flags"},"color":"white"},{"text":" cmd_gate_disabled=","color":"gray"},{"score":{"name":"#cmd_gate_disabled","objective":"macroengine.tick_flags"},"color":"white"},{"text":" max_len=","color":"gray"},{"plain":true,"storage":"macroengine:engine","nbt":"config.dynamic_cmd_max_len","interpret":false,"color":"white"}]
execute if data storage macroengine:engine config{cmd_gate_disabled:1b} run tellraw @s ["",{"text":" ⚠ cmd_gate is DISABLED: stored command strings run unchecked.","color":"red"}]
tellraw @s ["",{"text":" blocklist: ","color":"gray"},{"plain":true,"storage":"macroengine:engine","nbt":"cmd_blocklist","interpret":false,"color":"yellow"}]
tellraw @s ["",{"text":"[MACROENGINE] ","color":"#00AAAA","bold":true},{"text":"━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━","color":"#555555"}]
return 1
