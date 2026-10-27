# Gate 2 - run as the player who typed /trigger macroengine.permit set 1.
scoreboard players set #macroengine.permit vortaforge.gate 1
function macroengine:gate/refresh
schedule function macroengine:gate/rerun_load 1t replace
tellraw @a [{"translate":"macroengine.msg.gate.approved_by_prefix","fallback":"[macroengine] Approved by ","color":"green"},{"selector":"@s"},{"translate":"macroengine.msg.gate.approved_by_suffix","fallback":". An operator can revoke with /function macroengine:gate/revoke","color":"gray"}]
scoreboard players reset @s macroengine.permit
