# Gate 3 - per-player setup warning, shown once until the player decides or
# an operator resets the prompt. Called as the player from macroengine:setup
# (players online during load/reload) and gate/consent_tick (later joins).
#
# The Dialog states that this copy is controlled by the server/world
# operator, warns against entering sensitive information, and tells players
# who do not know or trust the server/world to cancel and leave. Continue
# opens macroengine:setup_warning_confirm; only its yes button grants Gate 3
# consent. Dialog buttons click through /trigger, so no operator permission
# or dynamic command template is involved.
tag @s add macroengine.prompted
tag @s add macroengine.setup_warned
scoreboard players enable @s macroengine.consent
tellraw @s [{"text":"[macroengine] A server warning dialog was opened for you. If it closes before you choose, ","color":"yellow"},{"text":"[Open warning again]","color":"aqua","click_event":{"action":"run_command","command":"/trigger macroengine.consent set 6"}},{"text":" or type /trigger macroengine.consent set 6","color":"gray"}]
dialog show @s macroengine:setup_warning
