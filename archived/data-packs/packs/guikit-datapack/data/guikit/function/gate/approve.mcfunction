# Gate 2 - operator approve (same result as a player's /trigger, for servers that approve via function).
scoreboard players set #guikit.permit vortaforge.gate 1
function guikit:gate/refresh
schedule function guikit:gate/rerun_load 1t replace
tellraw @a {"text":"[guikit] Approved by an operator.","color":"green"}
