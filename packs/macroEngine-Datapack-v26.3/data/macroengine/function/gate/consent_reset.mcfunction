# Gate 3 - withdraw consent and make the setup warning eligible to show again.
# Run as the player: /execute as <player> run function macroengine:gate/consent_reset
tag @s remove macroengine.consented
tag @s remove macroengine.prompted
tag @s remove macroengine.setup_warned
tag @s remove macroengine.setup_declined
scoreboard players reset @s macroengine.consent
