# macroengine:internal/systems/cb/time_left_step [INTERNAL]
# Pops the first entry of _cb_twork (a read-only copy of cb_queue). When its id == #macroengine.cb_cid,
# counts it in #macroengine.cb_tcount and keeps the smallest ticks_left in #macroengine.cb_tmin (-1 = none yet).
execute unless score #macroengine.open vortaforge.gate matches 1 run return 0
execute if entity @s[type=minecraft:player] unless entity @s[tag=macroengine.consented] unless score #macroengine.gate.3 vortaforge.gate matches 0 run return 0
data modify storage macroengine:engine _cb_tentry set from storage macroengine:engine _cb_twork[0]
data remove storage macroengine:engine _cb_twork[0]
scoreboard players set #macroengine.cb_eid macroengine.tmp 0
scoreboard players set #macroengine.cb_tlv macroengine.tmp 0
execute store result score #macroengine.cb_eid macroengine.tmp run data get storage macroengine:engine _cb_tentry.id
execute store result score #macroengine.cb_tlv macroengine.tmp run data get storage macroengine:engine _cb_tentry.ticks_left
execute if score #macroengine.cb_eid macroengine.tmp = #macroengine.cb_cid macroengine.tmp run scoreboard players add #macroengine.cb_tcount macroengine.tmp 1
execute if score #macroengine.cb_eid macroengine.tmp = #macroengine.cb_cid macroengine.tmp if score #macroengine.cb_tmin macroengine.tmp matches ..-1 run scoreboard players operation #macroengine.cb_tmin macroengine.tmp = #macroengine.cb_tlv macroengine.tmp
execute if score #macroengine.cb_eid macroengine.tmp = #macroengine.cb_cid macroengine.tmp if score #macroengine.cb_tlv macroengine.tmp < #macroengine.cb_tmin macroengine.tmp run scoreboard players operation #macroengine.cb_tmin macroengine.tmp = #macroengine.cb_tlv macroengine.tmp
execute if data storage macroengine:engine _cb_twork[0] run function macroengine:internal/systems/cb/time_left_step
