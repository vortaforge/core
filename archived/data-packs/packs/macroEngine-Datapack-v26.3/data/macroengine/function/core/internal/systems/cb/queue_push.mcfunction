# macroengine:systems/cb/internal/queue_push
# Macro: receives {cmd, delay, x, y, z}
# Appends an entry to macroengine:engine cb_queue list.
# Each entry: {cmd, delay, x, y, z, ticks_left}
# ticks_left is decremented each tick; fires when it hits 0.

execute unless score #macroengine.open vortaforge.gate matches 1 run return 0
execute if entity @s[type=minecraft:player] unless entity @s[tag=macroengine.consented] unless score #macroengine.gate.3 vortaforge.gate matches 0 run return 0
$data modify storage macroengine:engine cb_queue append value {cmd:"$(cmd)",x:$(x),y:$(y),z:$(z),ticks_left:$(delay)}
