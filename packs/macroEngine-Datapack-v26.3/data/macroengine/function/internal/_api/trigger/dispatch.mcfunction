execute unless score #macroengine.open vortaforge.gate matches 1 run return 0
execute if entity @s[type=minecraft:player] unless entity @s[tag=macroengine.consented] unless score #macroengine.gate.3 vortaforge.gate matches 0 run return 0
scoreboard players operation $tc_player macroengine.tmp = @s macroengine.action

scoreboard players set @s macroengine.action 0
scoreboard players enable @s macroengine.action

execute unless data storage macroengine:engine trigger_binds[0] run return 0

data modify storage macroengine:engine _tc_binds set from storage macroengine:engine trigger_binds

function macroengine:internal/_api/trigger/check_next
data remove storage macroengine:engine _tc_binds
data remove storage macroengine:engine _tc_current
