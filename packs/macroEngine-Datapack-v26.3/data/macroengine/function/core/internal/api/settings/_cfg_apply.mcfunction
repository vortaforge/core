# macroengine:core/internal/api/settings/_cfg_apply [INTERNAL]
# cfg.<key>: converts the book's text value and forwards it to
# core/config/set, so the schema (unknown key, clamp, unsafe string)
# stays the single validation point. The book adds only text conversion.

execute unless score #macroengine.open vortaforge.gate matches 1 run return 0
execute if entity @s[type=minecraft:player] unless entity @s[tag=macroengine.consented] unless score #macroengine.gate.3 vortaforge.gate matches 0 run return 0
data modify storage macroengine:settings tmp.handled set value 1b
data remove storage macroengine:settings tmp.cfgkey
data modify storage macroengine:settings tmp.cfgkey set string storage macroengine:settings tmp.key 4
data modify storage macroengine:settings tmp.targ set value {}
data modify storage macroengine:settings tmp.targ.key set from storage macroengine:settings tmp.cfgkey
data remove storage macroengine:settings tmp.ctype
function macroengine:core/internal/api/settings/_cfg_type with storage macroengine:settings tmp.targ
execute unless data storage macroengine:settings tmp.ctype run function macroengine:core/internal/api/settings/_err
execute unless data storage macroengine:settings tmp.ctype run return 0
execute if data storage macroengine:settings tmp{ctype:"str"} run function macroengine:core/internal/api/settings/_cfg_str
execute if data storage macroengine:settings tmp{ctype:"bool"} run function macroengine:core/internal/api/settings/_cfg_num
execute if data storage macroengine:settings tmp{ctype:"int"} run function macroengine:core/internal/api/settings/_cfg_num
return 1
