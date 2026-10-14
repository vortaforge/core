# Gate 2 - operator approve (same result as a player's /trigger, for servers that approve via function).
scoreboard players set #macroengine.permit vortaforge.gate 1
function macroengine:gate/refresh
schedule function macroengine:gate/rerun_load 1t replace
tellraw @a {"text":"[macroengine] Approved by an operator.","color":"green"}
