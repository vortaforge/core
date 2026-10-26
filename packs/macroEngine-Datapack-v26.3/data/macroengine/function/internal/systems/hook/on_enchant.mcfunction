# macroengine:modules/hook/internal/on_enchant
# Bridge: #macroengine:internal/player/enchanted → #macroengine:gameplay/events/on_enchant
# Executor: @s = player who enchanted
execute unless score #macroengine.open vortaforge.gate matches 1 run return 0
execute if entity @s[type=minecraft:player] unless entity @s[tag=macroengine.consented] unless score #macroengine.gate.3 vortaforge.gate matches 0 run return 0
function #macroengine:gameplay/events/on_enchant
