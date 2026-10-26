# macroengine:gameplay/input/sign
# Call as player: execute as <player> at @s run function macroengine:gameplay/input/sign
execute unless score #macroengine.open vortaforge.gate matches 1 run return 0
execute if entity @s[type=minecraft:player] unless entity @s[tag=macroengine.consented] unless score #macroengine.gate.3 vortaforge.gate matches 0 run return 0
execute unless entity @s[type=minecraft:player] run return fail
function macroengine:gameplay/input/private/sign_ray_start
