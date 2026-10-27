# Gate 3 - run as the player who agreed (legacy /trigger value 1, or yes in
# the setup-warning confirmation Dialog, value 4). Only @s is consented.
tag @s add macroengine.consented
tag @s add macroengine.setup_warned
tag @s remove macroengine.setup_declined
tag @s remove macroengine.prompted
scoreboard players reset @s macroengine.consent
tellraw @s {"text":"[macroengine] Consent recorded. An operator can withdraw it with /execute as <player> run function macroengine:gate/consent_reset","color":"green"}
