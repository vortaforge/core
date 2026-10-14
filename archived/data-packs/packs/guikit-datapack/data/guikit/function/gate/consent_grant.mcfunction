# Gate 3 - run as the player who typed /trigger guikit.consent set 1.
tag @s add guikit.consented
tag @s remove guikit.prompted
scoreboard players reset @s guikit.consent
tellraw @s {"text":"[guikit] Consent recorded. An operator can withdraw it with /function guikit:gate/consent_reset","color":"green"}
