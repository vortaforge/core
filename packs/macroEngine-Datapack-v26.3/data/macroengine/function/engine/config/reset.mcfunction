# macroengine:engine/config/reset
# Restores every runtime config value to its default and applies it.
execute unless score #macroengine.open vortaforge.gate matches 1 run return 0
execute if entity @s[type=minecraft:player] unless entity @s[tag=macroengine.consented] unless score #macroengine.gate.3 vortaforge.gate matches 0 run return 0
data remove storage macroengine:engine config
data remove storage macroengine:engine modules
scoreboard players set #macroengine.sys_time macroengine.tick_flags 1
scoreboard players set #macroengine.sys_player macroengine.tick_flags 1
scoreboard players set #macroengine.sys_queue macroengine.tick_flags 1
scoreboard players set #macroengine.sys_hud macroengine.tick_flags 1
scoreboard players set #macroengine.sys_admin macroengine.tick_flags 1
function macroengine:config
function macroengine:engine/config/apply
