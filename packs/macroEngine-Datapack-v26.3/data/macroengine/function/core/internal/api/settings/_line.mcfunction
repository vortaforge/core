# macroengine:core/internal/api/settings/_line [INTERNAL]
# Parses one "Key: Value" line (tmp.line) into tmp.key / tmp.value and
# hands it to _dispatch. Blank lines and lines whose first non-space
# character is # are comments. The key is lower-cased and must pass
# safe_name while still data - it is the only part of the line that is
# ever used to build an NBT path, and only through validated lookups.

execute unless score #macroengine.open vortaforge.gate matches 1 run return 0
execute if entity @s[type=minecraft:player] unless entity @s[tag=macroengine.consented] unless score #macroengine.gate.3 vortaforge.gate matches 0 run return 0
data modify storage macroengine:settings tmp.handled set value 0b
data modify storage macroengine:settings tmp.str set from storage macroengine:settings tmp.line
function macroengine:core/internal/api/settings/_trim_left
data modify storage macroengine:settings tmp.line set from storage macroengine:settings tmp.str
execute if data storage macroengine:settings tmp{line:""} run return 0
data remove storage macroengine:settings tmp.first
data modify storage macroengine:settings tmp.first set string storage macroengine:settings tmp.line 0 1
execute if data storage macroengine:settings tmp{first:"#"} run return 0

data remove storage macroengine:input string
data remove storage macroengine:input separator
data remove storage macroengine:input n
data remove storage macroengine:input keep_empty
data modify storage macroengine:input string set from storage macroengine:settings tmp.line
data modify storage macroengine:input separator set value ":"
data modify storage macroengine:input n set value 1
function macroengine:core/lib/string/split
execute unless data storage macroengine:output string.result[1] run function macroengine:core/internal/api/settings/_err
execute unless data storage macroengine:output string.result[1] run return 0
data modify storage macroengine:settings tmp.key set from storage macroengine:output string.result[0]
data modify storage macroengine:settings tmp.value set from storage macroengine:output string.result[1]

data modify storage macroengine:settings tmp.str set from storage macroengine:settings tmp.value
function macroengine:core/internal/api/settings/_trim_left
data modify storage macroengine:settings tmp.value set from storage macroengine:settings tmp.str

data modify storage macroengine:text s set from storage macroengine:settings tmp.key
function macroengine:core/internal/text/lower
execute if data storage macroengine:text err run data remove storage macroengine:settings tmp.key
execute unless data storage macroengine:text err run data modify storage macroengine:settings tmp.key set from storage macroengine:text out
function macroengine:core/internal/text/reset
execute unless data storage macroengine:settings tmp.key run function macroengine:core/internal/api/settings/_err
execute unless data storage macroengine:settings tmp.key run return 0

data remove storage macroengine:validate in
data modify storage macroengine:validate in.value set from storage macroengine:settings tmp.key
execute store result score #stbk_r macroengine.tmp run function macroengine:systems/validate/safe_name
execute unless score #stbk_r macroengine.tmp matches 1 run function macroengine:core/internal/api/settings/_err
execute unless score #stbk_r macroengine.tmp matches 1 run return 0

function macroengine:core/internal/api/settings/_dispatch
execute unless data storage macroengine:settings tmp{handled:1b} run function macroengine:core/internal/api/settings/_err
return 1
