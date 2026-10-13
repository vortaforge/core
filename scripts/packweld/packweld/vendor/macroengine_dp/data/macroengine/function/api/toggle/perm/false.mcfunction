# macroengine:api/toggle/perm/false — Disable the perm trigger module

execute unless entity @s[tag=macroengine.admin] run return 0

data modify storage macroengine:engine config.module_perm set value 0b
function macroengine:core/config/apply


tellraw @s ["",{"text":"[MACROENGINE] ","color":"#00AAAA","bold":true},{"text":"perm","color":"aqua"},{"text":" → ","color":"#555555"},{"text":"disabled","color":"red"}]