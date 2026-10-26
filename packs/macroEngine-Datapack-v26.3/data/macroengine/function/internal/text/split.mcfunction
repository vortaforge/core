# macroengine:internal/text/split
# INPUT  macroengine:text: s, sep (strings; "" splits into characters),
#          n (int, optional: 0 all, +n first n separators, -n last n separators),
#          keep_empty (byte, optional, default 0b)
# OUTPUT macroengine:text: out (list of strings)
# RETURN number of entries in out. Splitting "" yields [""].
execute unless score #macroengine.open vortaforge.gate matches 1 run return 0
execute if entity @s[type=minecraft:player] unless entity @s[tag=macroengine.consented] unless score #macroengine.gate.3 vortaforge.gate matches 0 run return 0
data remove storage macroengine:text err
data modify storage macroengine:text out set value []
execute unless data storage macroengine:text n run data modify storage macroengine:text n set value 0
execute store result score #macroengine.tx_keep macroengine.tmp run data get storage macroengine:text keep_empty
execute store result score #macroengine.tx_len macroengine.tmp run data get storage macroengine:text s
execute if score #macroengine.tx_len macroengine.tmp matches 0 run data modify storage macroengine:text out set value [""]
execute if score #macroengine.tx_len macroengine.tmp matches 0 run return 1
execute store result score #macroengine.tx_slen macroengine.tmp run data get storage macroengine:text sep
execute if score #macroengine.tx_slen macroengine.tmp matches 0 run scoreboard players set #macroengine.tx_i macroengine.tmp 0
execute if score #macroengine.tx_slen macroengine.tmp matches 0 run function macroengine:internal/text/split_chars
execute if score #macroengine.tx_slen macroengine.tmp matches 0 run return run data get storage macroengine:text out
data modify storage macroengine:text needle set from storage macroengine:text sep
execute store result score #macroengine.tx_total macroengine.tmp run function macroengine:internal/text/find
scoreboard players set #macroengine.tx_pos macroengine.tmp 0
function macroengine:internal/text/split_loop
scoreboard players operation #macroengine.tx_a macroengine.tmp = #macroengine.tx_pos macroengine.tmp
scoreboard players operation #macroengine.tx_b macroengine.tmp = #macroengine.tx_len macroengine.tmp
function macroengine:internal/text/_cut_ab
function macroengine:internal/text/split_emit
return run data get storage macroengine:text out
