# macroengine:api/toggle/perm/false — Disable the perm trigger module

execute unless score #macroengine.open vortaforge.gate matches 1 run return 0
execute if entity @s[type=minecraft:player] unless entity @s[tag=macroengine.consented] unless score #macroengine.gate.3 vortaforge.gate matches 0 run return 0
execute unless entity @s[tag=macroengine.admin] run return 0

data modify storage macroengine:engine config.module_perm set value 0b
function macroengine:core/config/apply


tellraw @s ["",{"text":"[MACROENGINE] ","color":"#00AAAA","bold":true},{"text":"perm","color":"aqua"},{"text":" → ","color":"#555555"},{"translate":"macroengine.ui.disabled","fallback":"disabled","color":"red"}]