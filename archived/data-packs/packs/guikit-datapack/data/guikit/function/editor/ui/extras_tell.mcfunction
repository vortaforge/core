execute unless score #guikit.open vortaforge.gate matches 1 run return 0
execute if entity @s[type=minecraft:player] unless entity @s[tag=guikit.consented] unless score #guikit.gate.3 vortaforge.gate matches 0 run return 0
tellraw @s [{"text":"[guikit] ","color":"gray"},{"text":"Current click rules. Keep leaves a rule unchanged.","color":"gold"}]
execute if data storage guikit:ed widget{confirm:1b} run tellraw @s {"text":"Confirm: on","color":"white"}
execute unless data storage guikit:ed widget{confirm:1b} run tellraw @s {"text":"Confirm: off","color":"white"}
execute if data storage guikit:ed widget{cd:60} run tellraw @s {"text":"Cooldown: 3s","color":"white"}
execute if data storage guikit:ed widget{cd:200} run tellraw @s {"text":"Cooldown: 10s","color":"white"}
execute if data storage guikit:ed widget{cd:600} run tellraw @s {"text":"Cooldown: 30s","color":"white"}
execute unless data storage guikit:ed widget.cd run tellraw @s {"text":"Cooldown: none","color":"white"}
execute if data storage guikit:ed widget{need:"vip"} run tellraw @s {"text":"Tag: vip","color":"white"}
execute if data storage guikit:ed widget{need:"member"} run tellraw @s {"text":"Tag: member","color":"white"}
execute if data storage guikit:ed widget{need:"staff"} run tellraw @s {"text":"Tag: staff","color":"white"}
execute unless data storage guikit:ed widget.need run tellraw @s {"text":"Tag: none","color":"white"}
