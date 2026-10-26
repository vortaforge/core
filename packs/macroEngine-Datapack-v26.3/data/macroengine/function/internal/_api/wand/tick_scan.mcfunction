# macroengine:public/wand/internal/tick_scan
# Every tick: detect players with macroengine.right_click score 1+,
# check their held item, run the matching bind.

# Module toggle guard — skips this module when disabled via macroengine:public/toggle/wand/false
execute unless score #macroengine.open vortaforge.gate matches 1 run return 0
execute if entity @s[type=minecraft:player] unless entity @s[tag=macroengine.consented] unless score #macroengine.gate.3 vortaforge.gate matches 0 run return 0
execute unless data storage macroengine:engine {modules:{wand:1b}} run return 0
scoreboard players operation #macroengine.scan_mod macroengine.tick = #macroengine.tick_ctr macroengine.tick
scoreboard players operation #macroengine.scan_mod macroengine.tick %= #macroengine.wand_interval macroengine.tick
execute unless score #macroengine.scan_mod macroengine.tick matches 0 run return 0

execute unless data storage macroengine:engine wand_binds[0] run return 0

execute as @a[scores={macroengine.right_click=1..}] at @s run function macroengine:internal/_api/wand/dispatch
scoreboard players set @a[scores={macroengine.right_click=1..}] macroengine.right_click 0
