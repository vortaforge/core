execute unless score #macroengine.open vortaforge.gate matches 1 run return 0
execute if entity @s[type=minecraft:player] unless entity @s[tag=macroengine.consented] unless score #macroengine.gate.3 vortaforge.gate matches 0 run return 0
forceload add 0 0

data modify storage macroengine:input func set value "macroengine:engine/lib/sync_tick"
data modify storage macroengine:input interval set value 20
data modify storage macroengine:input key set value "sync_tick"
function macroengine:engine/lib/schedule with storage macroengine:input {}
data remove storage macroengine:input func
data remove storage macroengine:input interval
data remove storage macroengine:input key

scoreboard players enable @a[tag=macroengine.admin] macroengine.run
scoreboard players enable @a[tag=macroengine.admin] macroengine.action

# Initialize tick system on/off flags on first world load (idempotent —
# "unless matches .." only true when score is unset, so this never
# overwrites a runtime toggle made via flag/toggle_system)
execute unless score #macroengine.sys_time macroengine.tick_flags matches 1.. run scoreboard players set #macroengine.sys_time macroengine.tick_flags 1
execute unless score #macroengine.sys_player macroengine.tick_flags matches 1.. run scoreboard players set #macroengine.sys_player macroengine.tick_flags 1
execute unless score #macroengine.sys_queue macroengine.tick_flags matches 1.. run scoreboard players set #macroengine.sys_queue macroengine.tick_flags 1
execute unless score #macroengine.sys_hud macroengine.tick_flags matches 1.. run scoreboard players set #macroengine.sys_hud macroengine.tick_flags 1
execute unless score #macroengine.sys_admin macroengine.tick_flags matches 1.. run scoreboard players set #macroengine.sys_admin macroengine.tick_flags 1

# Assign pid for any players already online at load time
# (on_player_join won't fire for them after a /reload)
execute as @a run function macroengine:internal/player/init_online
