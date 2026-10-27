# macroengine:core/internal/input/validate/_private/injection_hit [INTERNAL]
# Records one matched pattern (id + tier only - the needle text itself is
# deliberately NOT copied into the result, so the scan output never becomes
# a new home for the payload phrases).
execute unless score #macroengine.open vortaforge.gate matches 1 run return 0
execute if entity @s[type=minecraft:player] unless entity @s[tag=macroengine.consented] unless score #macroengine.gate.3 vortaforge.gate matches 0 run return 0
data modify storage macroengine:input_validate scan.hits append value {id:"",strong:0b}
data modify storage macroengine:input_validate scan.hits[-1].id set from storage macroengine:input_validate cur.id
data modify storage macroengine:input_validate scan.hits[-1].strong set from storage macroengine:input_validate cur.strong
execute if data storage macroengine:input_validate cur{strong:1b} run scoreboard players set #inj_strong macroengine.tmp 1
execute if data storage macroengine:input_validate cur{strong:1b} run scoreboard players add #inj_hits macroengine.tmp 1
execute unless data storage macroengine:input_validate cur{strong:1b} run scoreboard players set #inj_watch macroengine.tmp 1
return 1
