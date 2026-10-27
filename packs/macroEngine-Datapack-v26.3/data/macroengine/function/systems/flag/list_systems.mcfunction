# macroengine:systems/flag/list_systems — List all tick systems with their current on/off state
execute unless score #macroengine.open vortaforge.gate matches 1 run return 0
execute if entity @s[type=minecraft:player] unless entity @s[tag=macroengine.consented] unless score #macroengine.gate.3 vortaforge.gate matches 0 run return 0
tellraw @s [{"translate":"macroengine.msg.flag.systems_header","fallback":"[DL] Tick Systems","color":"gold","bold":true}]
tellraw @s [{"translate":"macroengine.msg.flag.time_label","fallback":"time: ","color":"gray"},{"score":{"name":"#sys_time","objective":"macroengine.tick_flags"},"color":"yellow"}]
tellraw @s [{"translate":"macroengine.msg.flag.player_label","fallback":"player: ","color":"gray"},{"score":{"name":"#sys_player","objective":"macroengine.tick_flags"},"color":"yellow"}]
tellraw @s [{"translate":"macroengine.msg.flag.queue_label","fallback":"queue: ","color":"gray"},{"score":{"name":"#sys_queue","objective":"macroengine.tick_flags"},"color":"yellow"}]
tellraw @s [{"translate":"macroengine.msg.flag.hud_label","fallback":"hud: ","color":"gray"},{"score":{"name":"#sys_hud","objective":"macroengine.tick_flags"},"color":"yellow"}]
tellraw @s [{"translate":"macroengine.msg.flag.admin_label","fallback":"admin: ","color":"gray"},{"score":{"name":"#sys_admin","objective":"macroengine.tick_flags"},"color":"yellow"}]
