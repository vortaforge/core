# Gate 3 - per-player consent via /trigger. Runs as a player who has not consented yet,
# called from the tick entry. No cheats, allowCommands or /op needed.
# Values: 1 = legacy direct agree, 2 = setup-warning Cancel, 3 = setup-warning no,
# 4 = setup-warning yes, 6 = reopen the setup warning. Other values are ignored.
scoreboard players enable @s macroengine.consent
execute if score @s macroengine.consent matches 1 run function macroengine:gate/consent_grant
execute if score @s macroengine.consent matches 2..3 run function macroengine:gate/setup_warning_deny
execute if score @s macroengine.consent matches 4 run function macroengine:gate/consent_grant
execute if score @s macroengine.consent matches 6 run tag @s remove macroengine.setup_warned
execute if score @s macroengine.consent matches 6 run tag @s remove macroengine.setup_declined
execute if score @s macroengine.consent matches 6 run scoreboard players reset @s macroengine.consent
execute if score @s macroengine.consent matches 5 run scoreboard players reset @s macroengine.consent
execute if score @s macroengine.consent matches 7.. run scoreboard players reset @s macroengine.consent
execute if entity @s[tag=!macroengine.consented,tag=!macroengine.setup_warned] run function macroengine:gate/consent_prompt
