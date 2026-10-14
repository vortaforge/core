# macro: $(url)     as player     (the game only opens http/https links)
execute unless score #guikit.open vortaforge.gate matches 1 run return 0
execute if entity @s[type=minecraft:player] unless entity @s[tag=guikit.consented] unless score #guikit.gate.3 vortaforge.gate matches 0 run return 0
$tellraw @s [{"text":"[GUI] ","color":"gray"},{"text":"$(url)","color":"aqua","underlined":true,"click_event":{"action":"open_url","url":"$(url)"}}]
