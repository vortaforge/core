# Gate 3 - run as the player who chose Cancel or no in the setup warning.
# Only @s changes state: the pack and every other player are unaffected.
tag @s add macroengine.setup_warned
tag @s add macroengine.setup_declined
tag @s remove macroengine.consented
scoreboard players reset @s macroengine.consent
tellraw @s [{"translate":"macroengine.msg.gate.deny_prefix","fallback":"[macroengine] macroEngine stays inactive for your player. If you do not know or trust this server/world, disconnect and leave. ","color":"red"},{"translate":"macroengine.msg.gate.review_warning","fallback":"[Review warning]","color":"aqua","click_event":{"action":"run_command","command":"/trigger macroengine.consent set 6"}}]
