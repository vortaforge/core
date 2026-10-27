# Ward test (CI only). See cmd_gate_default_off.mcfunction.
# @max_ticks 80
# @dummy ~ ~ ~

# The setup warning is a per-player Gate 3 choice: prompt is not consent,
# Cancel/no only decline @s, reopen clears that decline, and yes grants @s.
function macroengine:gate/approve
function macroengine:gate/consent_reset
function macroengine:gate/consent_prompt
execute store success score #setup_warn_test macroengine.tmp if entity @s[tag=macroengine.setup_warned]
assert score #setup_warn_test macroengine.tmp matches 1
execute store success score #setup_warn_test macroengine.tmp if entity @s[tag=macroengine.consented]
assert score #setup_warn_test macroengine.tmp matches 0

# Cancel from the first Dialog (trigger value 2).
scoreboard players set @s macroengine.consent 2
function macroengine:gate/consent_tick
execute store success score #setup_warn_test macroengine.tmp if entity @s[tag=macroengine.setup_declined]
assert score #setup_warn_test macroengine.tmp matches 1
execute store success score #setup_warn_test macroengine.tmp if entity @s[tag=macroengine.consented]
assert score #setup_warn_test macroengine.tmp matches 0

# Reopening clears the decline and shows the warning again.
scoreboard players set @s macroengine.consent 6
function macroengine:gate/consent_tick
execute store success score #setup_warn_test macroengine.tmp if entity @s[tag=macroengine.setup_declined]
assert score #setup_warn_test macroengine.tmp matches 0
execute store success score #setup_warn_test macroengine.tmp if entity @s[tag=macroengine.setup_warned]
assert score #setup_warn_test macroengine.tmp matches 1

# no from the confirmation Dialog (trigger value 3).
scoreboard players set @s macroengine.consent 3
function macroengine:gate/consent_tick
execute store success score #setup_warn_test macroengine.tmp if entity @s[tag=macroengine.setup_declined]
assert score #setup_warn_test macroengine.tmp matches 1

# Reopen once more, then yes (trigger value 4) grants only this player.
scoreboard players set @s macroengine.consent 6
function macroengine:gate/consent_tick
scoreboard players set @s macroengine.consent 4
function macroengine:gate/consent_tick
execute store success score #setup_warn_test macroengine.tmp if entity @s[tag=macroengine.consented]
assert score #setup_warn_test macroengine.tmp matches 1
execute store success score #setup_warn_test macroengine.tmp if entity @s[tag=macroengine.setup_declined]
assert score #setup_warn_test macroengine.tmp matches 0

function macroengine:gate/consent_reset
