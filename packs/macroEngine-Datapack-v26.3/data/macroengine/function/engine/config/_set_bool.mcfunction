# macroengine:engine/config/_set_bool [MACRO, INTERNAL]  $(key) is a schema key
execute unless score #macroengine.open vortaforge.gate matches 1 run return 0
execute if entity @s[type=minecraft:player] unless entity @s[tag=macroengine.consented] unless score #macroengine.gate.3 vortaforge.gate matches 0 run return 0
# FIX (v26.3-r1): a non-numeric value used to be coerced silently — `data get`
# on a string returns its LENGTH, so setting hud_rate to "abc" stored 3.
# NBT matching cannot express "is a string", so the type check is done the way
# the command parser sees it: expand the value into a scoreboard command. A
# string/compound/list fails to parse and leaves the sentinel in place.
scoreboard players set #macroengine.cfg_probe macroengine.tmp -2147483648
$execute if data storage macroengine:engine config_k.value run scoreboard players set #macroengine.cfg_probe macroengine.tmp $(value)
execute if score #macroengine.cfg_probe macroengine.tmp matches -2147483648 run return 0
execute store result score #macroengine.cfg_in macroengine.tmp run data get storage macroengine:engine config_in.value
$execute if score #macroengine.cfg_in macroengine.tmp matches ..0 run data modify storage macroengine:engine config.$(key) set value 0b
$execute if score #macroengine.cfg_in macroengine.tmp matches 1.. run data modify storage macroengine:engine config.$(key) set value 1b
function macroengine:engine/config/apply
return 1
