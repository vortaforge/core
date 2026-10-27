# macroengine:core/internal/api/settings/_permit_apply [INTERNAL]
# gate.permit: 1/approve runs gate/approve, 0/revoke runs gate/revoke.
# Guarded on the live permit score, so re-applying an unchanged book is
# a no-op (approve would otherwise re-run the load every time).

execute unless score #macroengine.open vortaforge.gate matches 1 run return 0
execute if entity @s[type=minecraft:player] unless entity @s[tag=macroengine.consented] unless score #macroengine.gate.3 vortaforge.gate matches 0 run return 0
data modify storage macroengine:settings tmp.handled set value 1b
function macroengine:core/internal/api/settings/_bool
execute unless data storage macroengine:settings tmp{bvalid:1b} run function macroengine:core/internal/api/settings/_err
execute unless data storage macroengine:settings tmp{bvalid:1b} run return 0
execute if data storage macroengine:settings tmp{bval:1b} unless score #macroengine.permit vortaforge.gate matches 1 run function macroengine:gate/approve
execute if data storage macroengine:settings tmp{bval:0b} if score #macroengine.permit vortaforge.gate matches 1 run function macroengine:gate/revoke
scoreboard players add #stbk_ok macroengine.tmp 1
return 1
