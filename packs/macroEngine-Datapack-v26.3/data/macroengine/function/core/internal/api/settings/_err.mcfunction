# macroengine:core/internal/api/settings/_err [INTERNAL]
# Records the current tmp.line as rejected. The line itself is the error
# message - api/settings/apply prints the rejected list back to @s.

execute unless score #macroengine.open vortaforge.gate matches 1 run return 0
execute if entity @s[type=minecraft:player] unless entity @s[tag=macroengine.consented] unless score #macroengine.gate.3 vortaforge.gate matches 0 run return 0
data modify storage macroengine:settings result.errors append from storage macroengine:settings tmp.line
scoreboard players add #stbk_err macroengine.tmp 1
return 0
