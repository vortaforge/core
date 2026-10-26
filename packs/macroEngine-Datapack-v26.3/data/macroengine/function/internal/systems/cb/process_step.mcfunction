# macroengine:modules/cb/internal/process_step
# Pops first entry from _cb_work.
# ticks_left == 1 → fire now.
# ticks_left > 1  → decrement and return to cb_queue.

# Pop first entry
execute unless score #macroengine.open vortaforge.gate matches 1 run return 0
execute if entity @s[type=minecraft:player] unless entity @s[tag=macroengine.consented] unless score #macroengine.gate.3 vortaforge.gate matches 0 run return 0
data modify storage macroengine:engine _cb_entry set from storage macroengine:engine _cb_work[0]
data remove storage macroengine:engine _cb_work[0]

# Decrement ticks_left
execute store result score #macroengine.cb_tl macroengine.tmp run data get storage macroengine:engine _cb_entry.ticks_left
scoreboard players remove #macroengine.cb_tl macroengine.tmp 1

# All entries share one temporary command block per location, and a second setblock in
# the same window would overwrite the first before it ran. So after one fires, anything
# else that is ready is pushed back by 1 tick (cooldown #macroengine.cb_cd, 2 ticks between fires).
execute if score #macroengine.cb_tl macroengine.tmp matches ..0 if score #macroengine.cb_cd macroengine.tmp matches 1.. run scoreboard players set #macroengine.cb_tl macroengine.tmp 1
execute if score #macroengine.cb_tl macroengine.tmp matches ..0 run scoreboard players set #macroengine.cb_cd macroengine.tmp 2
execute if score #macroengine.cb_tl macroengine.tmp matches ..0 run function macroengine:internal/systems/cb/fire_entry

execute unless score #macroengine.cb_tl macroengine.tmp matches ..0 run execute store result storage macroengine:engine _cb_entry.ticks_left int 1 run scoreboard players get #macroengine.cb_tl macroengine.tmp
execute unless score #macroengine.cb_tl macroengine.tmp matches ..0 run data modify storage macroengine:engine cb_queue append from storage macroengine:engine _cb_entry

data remove storage macroengine:engine _cb_entry

# Recurse if more entries remain
execute if data storage macroengine:engine _cb_work[0] run function macroengine:internal/systems/cb/process_step
