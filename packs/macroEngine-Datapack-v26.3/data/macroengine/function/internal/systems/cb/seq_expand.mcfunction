# macroengine:modules/cb/internal/seq_expand
# Converts cb.cmds list + interval into individual cb_queue entries.
# Each entry gets ticks_left = (index + 1) * interval.

# Init sequence state
execute unless score #macroengine.open vortaforge.gate matches 1 run return 0
execute if entity @s[type=minecraft:player] unless entity @s[tag=macroengine.consented] unless score #macroengine.gate.3 vortaforge.gate matches 0 run return 0
data modify storage macroengine:engine _cb_seq set from storage macroengine:input cb
execute store result score #macroengine.cb_seq_idx macroengine.tmp run data get storage macroengine:engine _cb_seq.interval
scoreboard players set #macroengine.cb_seq_step macroengine.tmp 0
# One id for the whole sequence (cancel_id cancels every remaining step)
scoreboard players add #macroengine.cb_next_id macroengine.tmp 1
execute store result storage macroengine:output cb_id int 1 run scoreboard players get #macroengine.cb_next_id macroengine.tmp

execute if data storage macroengine:engine _cb_seq.cmds[0] run function macroengine:internal/systems/cb/seq_expand_loop
data remove storage macroengine:engine _cb_seq
