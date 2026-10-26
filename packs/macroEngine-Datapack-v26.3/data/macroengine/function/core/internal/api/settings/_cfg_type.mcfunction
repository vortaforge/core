# macroengine:core/internal/api/settings/_cfg_type [INTERNAL - macro]
# INPUT: $(key) - a config key that passed safe_name. Copies its schema
# type ("bool"/"int"/"str") to tmp.ctype, the same read
# core/config/_set_lookup does; an unknown key leaves tmp.ctype unset.

execute unless score #macroengine.open vortaforge.gate matches 1 run return 0
execute if entity @s[type=minecraft:player] unless entity @s[tag=macroengine.consented] unless score #macroengine.gate.3 vortaforge.gate matches 0 run return 0
$data modify storage macroengine:settings tmp.ctype set from storage macroengine:engine config_schema.$(key).t
