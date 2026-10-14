# Gate 1 - version gate (vortaforge/core). Called first from guikit:core/load.
# Refuses to run when this world was last loaded by a NEWER version of this pack
# (downgrade protection). A first install or an upgrade passes and records the version.
# Toggle: function guikit:gate/set/1_off | 1_on. Default: on.
# Safeguard, not a sandbox: a datapack is plain text and the checks can be deleted.
# Non-bypassable enforcement belongs in a Fabric mod.
scoreboard objectives add vortaforge.gate dummy
scoreboard objectives add guikit.permit trigger
scoreboard objectives add guikit.consent trigger
execute unless score #guikit.gate.1 vortaforge.gate = #guikit.gate.1 vortaforge.gate run scoreboard players set #guikit.gate.1 vortaforge.gate 1
execute unless score #guikit.gate.2 vortaforge.gate = #guikit.gate.2 vortaforge.gate run scoreboard players set #guikit.gate.2 vortaforge.gate 1
execute unless score #guikit.gate.3 vortaforge.gate = #guikit.gate.3 vortaforge.gate run scoreboard players set #guikit.gate.3 vortaforge.gate 1
execute unless score #guikit.installed vortaforge.gate = #guikit.installed vortaforge.gate run scoreboard players set #guikit.installed vortaforge.gate 0
scoreboard players set #guikit.expected vortaforge.gate 1
scoreboard players set #guikit.version vortaforge.gate 0
execute if score #guikit.installed vortaforge.gate <= #guikit.expected vortaforge.gate run scoreboard players set #guikit.version vortaforge.gate 1
execute if score #guikit.version vortaforge.gate matches 1 run scoreboard players operation #guikit.installed vortaforge.gate = #guikit.expected vortaforge.gate
execute if score #guikit.version vortaforge.gate matches 0 if score #guikit.gate.1 vortaforge.gate matches 0 run scoreboard players set #guikit.version vortaforge.gate 1
function guikit:gate/refresh
execute if score #guikit.version vortaforge.gate matches 0 run tellraw @a {"text":"[guikit] This world was saved with a newer version of this datapack. guikit stays inactive (version gate).","color":"red"}
execute if score #guikit.version vortaforge.gate matches 1 unless score #guikit.gate.2 vortaforge.gate matches 0 unless score #guikit.permit vortaforge.gate matches 1 run function guikit:gate/permit_prompt
