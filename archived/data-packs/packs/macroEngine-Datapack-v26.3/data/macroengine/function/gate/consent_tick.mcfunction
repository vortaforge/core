# Gate 3 - per-player consent via /trigger. Runs as a player who has not consented yet,
# called from the tick entry. No cheats, allowCommands or /op needed.
scoreboard players enable @s macroengine.consent
execute if score @s macroengine.consent matches 1 run function macroengine:gate/consent_grant
execute if score @s macroengine.consent matches 2.. run scoreboard players reset @s macroengine.consent
execute if entity @s[tag=!macroengine.consented,tag=!macroengine.prompted] run function macroengine:gate/consent_prompt
