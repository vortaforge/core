# macroengine:core/internal/api/settings/_block_root [INTERNAL]
# Normalises tmp.value into tmp.root and sets tmp.rvalid. A blocklist
# entry is a command root: 1..32 chars, lower-cased, no spaces, no quote
# or backslash, no control characters - the same checks the gate applies
# to a root before comparing it, so an entry that could never match is
# rejected here instead of being stored.

execute unless score #macroengine.open vortaforge.gate matches 1 run return 0
execute if entity @s[type=minecraft:player] unless entity @s[tag=macroengine.consented] unless score #macroengine.gate.3 vortaforge.gate matches 0 run return 0
data modify storage macroengine:settings tmp.rvalid set value 1b
function macroengine:core/internal/api/settings/_bool
data remove storage macroengine:settings tmp.root
data modify storage macroengine:settings tmp.root set from storage macroengine:settings tmp.value_lc
execute unless data storage macroengine:settings tmp.root run data modify storage macroengine:settings tmp.rvalid set value 0b
execute store result score #stbk_len macroengine.tmp run data get storage macroengine:settings tmp.root
execute if score #stbk_len macroengine.tmp matches ..0 run data modify storage macroengine:settings tmp.rvalid set value 0b
execute if score #stbk_len macroengine.tmp matches 33.. run data modify storage macroengine:settings tmp.rvalid set value 0b
data modify storage macroengine:text s set from storage macroengine:settings tmp.root
execute store result score #stbk_hit macroengine.tmp run function macroengine:core/internal/text/safe
function macroengine:core/internal/text/reset
execute if score #stbk_hit macroengine.tmp matches 0 run data modify storage macroengine:settings tmp.rvalid set value 0b
data modify storage macroengine:text s set from storage macroengine:settings tmp.root
execute store result score #stbk_hit macroengine.tmp run function macroengine:core/internal/text/ctl
function macroengine:core/internal/text/reset
execute if score #stbk_hit macroengine.tmp matches 1 run data modify storage macroengine:settings tmp.rvalid set value 0b
data remove storage macroengine:input string
data remove storage macroengine:input separator
data remove storage macroengine:input n
data remove storage macroengine:input keep_empty
data modify storage macroengine:input string set from storage macroengine:settings tmp.root
data modify storage macroengine:input separator set value " "
data modify storage macroengine:input n set value 1
function macroengine:core/lib/string/split
execute if data storage macroengine:output string.result[1] run data modify storage macroengine:settings tmp.rvalid set value 0b
execute if data storage macroengine:settings tmp{rvalid:1b} run return 1
return 0
