# macroengine:internal/text/replace
# INPUT  macroengine:text: s, needle, rep (strings), n (int, optional: 0 all, +n first n, -n last n)
# OUTPUT macroengine:text: out (string)   on failure: err, out unset
# RETURN number of replacements. s and rep must not contain a quote or backslash.
execute unless score #macroengine.open vortaforge.gate matches 1 run return 0
execute if entity @s[type=minecraft:player] unless entity @s[tag=macroengine.consented] unless score #macroengine.gate.3 vortaforge.gate matches 0 run return 0
data remove storage macroengine:text err
data remove storage macroengine:text out
execute unless data storage macroengine:text n run data modify storage macroengine:text n set value 0
data modify storage macroengine:text r set value {}
data modify storage macroengine:text r.s set from storage macroengine:text s
data modify storage macroengine:text r.needle set from storage macroengine:text needle
data modify storage macroengine:text r.rep set from storage macroengine:text rep
data modify storage macroengine:text r.n set from storage macroengine:text n
execute store result score #macroengine.tx_ok macroengine.tmp run function macroengine:internal/text/safe
execute if score #macroengine.tx_ok macroengine.tmp matches 0 run data modify storage macroengine:text err set value "replace: the string contains a quote or backslash"
execute if score #macroengine.tx_ok macroengine.tmp matches 0 run return 0
data modify storage macroengine:text s set from storage macroengine:text r.rep
execute store result score #macroengine.tx_ok macroengine.tmp run function macroengine:internal/text/safe
data modify storage macroengine:text s set from storage macroengine:text r.s
execute if score #macroengine.tx_ok macroengine.tmp matches 0 run data modify storage macroengine:text err set value "replace: the replacement contains a quote or backslash"
execute if score #macroengine.tx_ok macroengine.tmp matches 0 run return 0
data modify storage macroengine:text needle set from storage macroengine:text r.needle
data modify storage macroengine:text n set from storage macroengine:text r.n
execute store result score #macroengine.tx_total macroengine.tmp run function macroengine:internal/text/find
execute if score #macroengine.tx_total macroengine.tmp matches 0 run data modify storage macroengine:text out set from storage macroengine:text r.s
execute if score #macroengine.tx_total macroengine.tmp matches 0 run return 0
data modify storage macroengine:text pc set value []
scoreboard players set #macroengine.tx_pos macroengine.tmp 0
function macroengine:internal/text/replace_loop
execute store result score #macroengine.tx_len macroengine.tmp run data get storage macroengine:text s
scoreboard players operation #macroengine.tx_a macroengine.tmp = #macroengine.tx_pos macroengine.tmp
scoreboard players operation #macroengine.tx_b macroengine.tmp = #macroengine.tx_len macroengine.tmp
function macroengine:internal/text/_cut_ab
data modify storage macroengine:text pc append from storage macroengine:text win
function macroengine:internal/text/join
return run scoreboard players get #macroengine.tx_total macroengine.tmp
