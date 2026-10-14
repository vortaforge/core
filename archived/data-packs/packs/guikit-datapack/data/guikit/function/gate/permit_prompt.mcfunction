# Gate 2 - shown on load while the pack is not yet approved.
tellraw @a [{"text":"[guikit] This datapack is inactive until a player approves it. ","color":"yellow"},{"text":"[Approve]","color":"green","click_event":{"action":"run_command","command":"/trigger guikit.permit set 1"}},{"text":" or type /trigger guikit.permit set 1","color":"gray"}]
