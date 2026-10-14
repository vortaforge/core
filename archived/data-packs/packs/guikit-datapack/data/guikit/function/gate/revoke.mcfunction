# Gate 2 - operator revoke: the pack goes inactive again until re-approved.
scoreboard players set #guikit.permit vortaforge.gate 0
function guikit:gate/refresh
tellraw @a {"text":"[guikit] Approval revoked.","color":"yellow"}
function guikit:gate/permit_prompt
