# macroengine:api/trigger/unbind_all
execute if data storage macroengine:engine modules{trigger:0b} run return 0
data modify storage macroengine:engine trigger_binds set value []
