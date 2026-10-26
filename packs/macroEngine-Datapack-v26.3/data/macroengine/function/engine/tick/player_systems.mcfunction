execute unless score #macroengine.open vortaforge.gate matches 1 run return 0
execute if entity @s[type=minecraft:player] unless entity @s[tag=macroengine.consented] unless score #macroengine.gate.3 vortaforge.gate matches 0 run return 0
execute as @a[scores={macroengine.run=1..}] run function #macroengine:admin/run
scoreboard players set @a[scores={macroengine.run=1..}] macroengine.run 0
scoreboard players enable @a[scores={macroengine.run=-1..}] macroengine.run

execute as @a[scores={macroengine.action=1..}] run function macroengine:internal/_api/trigger/dispatch

function macroengine:internal/_api/interaction/tick_scan

function macroengine:internal/_api/perm/trigger/tick_start

function macroengine:internal/_api/wand/tick_scan
function macroengine:internal/systems/hook/tick_scan

function macroengine:internal/systems/geo/region_watch/tick_scan
function macroengine:internal/_api/cmd/freeze/tick

execute as @e[type=minecraft:item] if items entity @s contents *[minecraft:custom_data~{macroengine:{input:1b}}] at @s on origin run data merge entity @n[type=minecraft:item,distance=..0.1] {PickupDelay:0s}
kill @e[type=minecraft:item,nbt={Item:{components:{"minecraft:custom_data":{macroengine:{input:1b,inputItem:"anvil"}}}}}]
