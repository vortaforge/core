# Clear previous owner tag (multiplayer-safe)
execute unless score #macroengine.open vortaforge.gate matches 1 run return 0
execute if entity @s[type=minecraft:player] unless entity @s[tag=macroengine.consented] unless score #macroengine.gate.3 vortaforge.gate matches 0 run return 0
tag @a remove macroengine.cbm_owner
tag @s add macroengine.cbm_owner

# Store owner UUID for later lookup
data modify storage macroengine:input cbm.owner set from entity @s UUID

# Remove any nearby existing input minecart, then summon fresh
kill @e[type=minecraft:command_block_minecart,tag=macroengine.input,distance=..2]
summon minecraft:command_block_minecart ~ ~ ~ {OnGround:1b,UpdateLastExecution:1b,Command:"",Tags:["macroengine.input"],TrackOutput:1b}
