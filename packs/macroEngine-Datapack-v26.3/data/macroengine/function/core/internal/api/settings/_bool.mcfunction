# macroengine:core/internal/api/settings/_bool [INTERNAL]
# Normalises tmp.value into tmp.bval (byte) with tmp.bvalid telling
# whether the value was a boolean word at all. tmp.value_lc (the
# lower-cased value) is left in place for callers that just need the
# case-folded string (blocklist roots). Accepted words, case-insensitive:
# on/off, true/false, yes/no, enable/disable, 1/0.

execute unless score #macroengine.open vortaforge.gate matches 1 run return 0
execute if entity @s[type=minecraft:player] unless entity @s[tag=macroengine.consented] unless score #macroengine.gate.3 vortaforge.gate matches 0 run return 0
data modify storage macroengine:settings tmp.bvalid set value 0b
data modify storage macroengine:settings tmp.bval set value 0b
data remove storage macroengine:settings tmp.value_lc
data modify storage macroengine:text s set from storage macroengine:settings tmp.value
function macroengine:core/internal/text/lower
execute unless data storage macroengine:text err run data modify storage macroengine:settings tmp.value_lc set from storage macroengine:text out
function macroengine:core/internal/text/reset
execute if data storage macroengine:settings tmp{value_lc:"1"} run data modify storage macroengine:settings tmp.bvalid set value 1b
execute if data storage macroengine:settings tmp{value_lc:"1"} run data modify storage macroengine:settings tmp.bval set value 1b
execute if data storage macroengine:settings tmp{value_lc:"on"} run data modify storage macroengine:settings tmp.bvalid set value 1b
execute if data storage macroengine:settings tmp{value_lc:"on"} run data modify storage macroengine:settings tmp.bval set value 1b
execute if data storage macroengine:settings tmp{value_lc:"true"} run data modify storage macroengine:settings tmp.bvalid set value 1b
execute if data storage macroengine:settings tmp{value_lc:"true"} run data modify storage macroengine:settings tmp.bval set value 1b
execute if data storage macroengine:settings tmp{value_lc:"yes"} run data modify storage macroengine:settings tmp.bvalid set value 1b
execute if data storage macroengine:settings tmp{value_lc:"yes"} run data modify storage macroengine:settings tmp.bval set value 1b
execute if data storage macroengine:settings tmp{value_lc:"enable"} run data modify storage macroengine:settings tmp.bvalid set value 1b
execute if data storage macroengine:settings tmp{value_lc:"enable"} run data modify storage macroengine:settings tmp.bval set value 1b
execute if data storage macroengine:settings tmp{value_lc:"enabled"} run data modify storage macroengine:settings tmp.bvalid set value 1b
execute if data storage macroengine:settings tmp{value_lc:"enabled"} run data modify storage macroengine:settings tmp.bval set value 1b
execute if data storage macroengine:settings tmp{value_lc:"approve"} run data modify storage macroengine:settings tmp.bvalid set value 1b
execute if data storage macroengine:settings tmp{value_lc:"approve"} run data modify storage macroengine:settings tmp.bval set value 1b
execute if data storage macroengine:settings tmp{value_lc:"0"} run data modify storage macroengine:settings tmp.bvalid set value 1b
execute if data storage macroengine:settings tmp{value_lc:"off"} run data modify storage macroengine:settings tmp.bvalid set value 1b
execute if data storage macroengine:settings tmp{value_lc:"false"} run data modify storage macroengine:settings tmp.bvalid set value 1b
execute if data storage macroengine:settings tmp{value_lc:"no"} run data modify storage macroengine:settings tmp.bvalid set value 1b
execute if data storage macroengine:settings tmp{value_lc:"disable"} run data modify storage macroengine:settings tmp.bvalid set value 1b
execute if data storage macroengine:settings tmp{value_lc:"disabled"} run data modify storage macroengine:settings tmp.bvalid set value 1b
execute if data storage macroengine:settings tmp{value_lc:"revoke"} run data modify storage macroengine:settings tmp.bvalid set value 1b
execute if data storage macroengine:settings tmp{bvalid:1b} run return 1
return 0
