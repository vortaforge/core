# macroengine:modules/geo/region_watch/internal/tick_scan
# Called directly from core/tick/queue_systems.mcfunction.
# If region_watches is non-empty, checks all regions for each player.

# Module toggle guard — skips this module when disabled via macroengine:public/toggle/geo/false
execute unless score #macroengine.open vortaforge.gate matches 1 run return 0
execute if entity @s[type=minecraft:player] unless entity @s[tag=macroengine.consented] unless score #macroengine.gate.3 vortaforge.gate matches 0 run return 0
execute unless data storage macroengine:engine {modules:{geo:1b}} run return 0
scoreboard players operation #macroengine.scan_mod macroengine.tick = #macroengine.tick_ctr macroengine.tick
scoreboard players operation #macroengine.scan_mod macroengine.tick %= #macroengine.geo_interval macroengine.tick
execute unless score #macroengine.scan_mod macroengine.tick matches 0 run return 0

execute unless data storage macroengine:engine region_watches run return 0

execute as @a run function macroengine:internal/systems/geo/region_watch/player_scan
