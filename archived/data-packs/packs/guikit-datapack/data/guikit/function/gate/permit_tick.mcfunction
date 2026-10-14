# Gate 2 - permission via /trigger. Runs from the tick entry only while the pack is not approved.
# /trigger works without cheats, allowCommands or /op, so nobody has to enable those for this.
# A trigger is not authenticated: on a server with untrusted players any player can approve.
# Servers that need real access control should call guikit:gate/set/2_on and approve through a function (operator) instead.
scoreboard players enable @a guikit.permit
execute as @a[scores={guikit.permit=1}] run function guikit:gate/permit_grant
execute as @a[scores={guikit.permit=2..}] run scoreboard players reset @s guikit.permit
