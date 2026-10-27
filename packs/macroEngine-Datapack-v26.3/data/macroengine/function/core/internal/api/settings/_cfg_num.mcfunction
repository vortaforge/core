# macroengine:core/internal/api/settings/_cfg_num [INTERNAL]
# Bool keys accept words ("on"/"off"/...) via _bool and fall back to a
# plain number; int keys only accept a number (the string library's
# to_number leaves its result unset on failure). Either way the value
# reaches core/config/set as a number and is validated/clamped there.

execute unless score #macroengine.open vortaforge.gate matches 1 run return 0
execute if entity @s[type=minecraft:player] unless entity @s[tag=macroengine.consented] unless score #macroengine.gate.3 vortaforge.gate matches 0 run return 0
data modify storage macroengine:engine config_in set value {}
data modify storage macroengine:engine config_in.key set from storage macroengine:settings tmp.cfgkey
data modify storage macroengine:settings tmp.bvalid set value 0b
execute if data storage macroengine:settings tmp{ctype:"bool"} run function macroengine:core/internal/api/settings/_bool
execute if data storage macroengine:settings tmp{bvalid:1b} run data modify storage macroengine:engine config_in.value set from storage macroengine:settings tmp.bval
execute unless data storage macroengine:settings tmp{bvalid:1b} run data remove storage macroengine:input string
execute unless data storage macroengine:settings tmp{bvalid:1b} run data modify storage macroengine:input string set from storage macroengine:settings tmp.value
execute unless data storage macroengine:settings tmp{bvalid:1b} run function macroengine:core/lib/string/to_number
execute unless data storage macroengine:settings tmp{bvalid:1b} run data modify storage macroengine:engine config_in.value set from storage macroengine:output string.result
execute unless data storage macroengine:engine config_in.value run function macroengine:core/internal/api/settings/_err
execute unless data storage macroengine:engine config_in.value run return 0
execute store result score #stbk_r macroengine.tmp run function macroengine:core/config/set
execute if score #stbk_r macroengine.tmp matches 1 run scoreboard players add #stbk_ok macroengine.tmp 1
execute unless score #stbk_r macroengine.tmp matches 1 run function macroengine:core/internal/api/settings/_err
return 1
