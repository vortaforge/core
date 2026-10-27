# macroengine:core/internal/api/settings/_view [INTERNAL]
# Snapshots the live values the settings book displays into
# macroengine:settings view (plain ints, so the _give macro can print
# them). Gates come straight from their scores, so the book always shows
# what `execute if score` would decide right now - no second source of
# truth. Every field is defaulted first: a missing score or config key on
# a fresh world must never leave a macro argument unset.

execute unless score #macroengine.open vortaforge.gate matches 1 run return 0
execute if entity @s[type=minecraft:player] unless entity @s[tag=macroengine.consented] unless score #macroengine.gate.3 vortaforge.gate matches 0 run return 0
data modify storage macroengine:settings view set value {g1:1,g2:1,g3:1,g4:1,g5:1,permit:0,cmdgate:1,dynamic:0,maxlen:256,mcmd:1,mperm:1,tick:1,qmax:256,log:3,vmax:64}
execute if score #macroengine.gate.1 vortaforge.gate matches -2147483648..2147483647 store result storage macroengine:settings view.g1 int 1 run scoreboard players get #macroengine.gate.1 vortaforge.gate
execute if score #macroengine.gate.2 vortaforge.gate matches -2147483648..2147483647 store result storage macroengine:settings view.g2 int 1 run scoreboard players get #macroengine.gate.2 vortaforge.gate
execute if score #macroengine.gate.3 vortaforge.gate matches -2147483648..2147483647 store result storage macroengine:settings view.g3 int 1 run scoreboard players get #macroengine.gate.3 vortaforge.gate
execute if score #macroengine.gate.4 vortaforge.gate matches -2147483648..2147483647 store result storage macroengine:settings view.g4 int 1 run scoreboard players get #macroengine.gate.4 vortaforge.gate
execute if score #macroengine.gate.5 vortaforge.gate matches -2147483648..2147483647 store result storage macroengine:settings view.g5 int 1 run scoreboard players get #macroengine.gate.5 vortaforge.gate
execute if score #macroengine.permit vortaforge.gate matches -2147483648..2147483647 store result storage macroengine:settings view.permit int 1 run scoreboard players get #macroengine.permit vortaforge.gate
execute if data storage macroengine:engine config{cmd_gate_disabled:1b} run data modify storage macroengine:settings view.cmdgate set value 0
execute if data storage macroengine:engine config.dynamic_cmd store result storage macroengine:settings view.dynamic int 1 run data get storage macroengine:engine config.dynamic_cmd
execute if data storage macroengine:engine config.dynamic_cmd_max_len store result storage macroengine:settings view.maxlen int 1 run data get storage macroengine:engine config.dynamic_cmd_max_len
execute if data storage macroengine:engine config.module_cmd store result storage macroengine:settings view.mcmd int 1 run data get storage macroengine:engine config.module_cmd
execute if data storage macroengine:engine config.module_perm store result storage macroengine:settings view.mperm int 1 run data get storage macroengine:engine config.module_perm
execute if data storage macroengine:engine config.tick_rate store result storage macroengine:settings view.tick int 1 run data get storage macroengine:engine config.tick_rate
execute if data storage macroengine:engine config.queue_max_depth store result storage macroengine:settings view.qmax int 1 run data get storage macroengine:engine config.queue_max_depth
execute if data storage macroengine:engine config.log_level store result storage macroengine:settings view.log int 1 run data get storage macroengine:engine config.log_level
execute if data storage macroengine:engine config.validate_max_name store result storage macroengine:settings view.vmax int 1 run data get storage macroengine:engine config.validate_max_name
return 1
