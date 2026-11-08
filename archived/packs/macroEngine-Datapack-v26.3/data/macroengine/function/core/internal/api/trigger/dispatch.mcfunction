# macroengine:core/internal/api/trigger/dispatch
scoreboard players operation $tc_player macroengine.tmp = @s macroengine.action

scoreboard players set @s macroengine.action 0
scoreboard players enable @s macroengine.action

execute unless data storage macroengine:engine trigger_binds[0] run return 0

data modify storage macroengine:engine _tc_binds set from storage macroengine:engine trigger_binds

function macroengine:core/internal/api/trigger/check_next
data remove storage macroengine:engine _tc_binds
data remove storage macroengine:engine _tc_current
