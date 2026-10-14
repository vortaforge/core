# Gate 3 - per-player consent via /trigger. Runs as a player who has not consented yet,
# called from the tick entry. No cheats, allowCommands or /op needed.
scoreboard players enable @s guikit.consent
execute if score @s guikit.consent matches 1 run function guikit:gate/consent_grant
execute if score @s guikit.consent matches 2.. run scoreboard players reset @s guikit.consent
execute if entity @s[tag=!guikit.consented,tag=!guikit.prompted] run function guikit:gate/consent_prompt
