# macroengine:core/internal/api/settings/_cfg_str [INTERNAL]
# String config keys take the book value verbatim (case preserved);
# core/config/set rejects it if it is not a safe, short enough string.

execute unless score #macroengine.open vortaforge.gate matches 1 run return 0
execute if entity @s[type=minecraft:player] unless entity @s[tag=macroengine.consented] unless score #macroengine.gate.3 vortaforge.gate matches 0 run return 0
data modify storage macroengine:engine config_in set value {}
data modify storage macroengine:engine config_in.key set from storage macroengine:settings tmp.cfgkey
data modify storage macroengine:engine config_in.value set from storage macroengine:settings tmp.value
execute store result score #stbk_r macroengine.tmp run function macroengine:core/config/set
execute if score #stbk_r macroengine.tmp matches 1 run scoreboard players add #stbk_ok macroengine.tmp 1
execute unless score #stbk_r macroengine.tmp matches 1 run function macroengine:core/internal/api/settings/_err
return 1
