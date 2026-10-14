# macro: $(id) $(fn)     as player
# Non-destructive presence test (count 0), then dispatch. Runs once per click per matching id.
execute unless score #guikit.open vortaforge.gate matches 1 run return 0
execute if entity @s[type=minecraft:player] unless entity @s[tag=guikit.consented] unless score #guikit.gate.3 vortaforge.gate matches 0 run return 0
$execute store result score #hit guikit.tmp run clear @s *[custom_data~{guikit:{w:1b,id:"$(id)"}}] 0
$execute if score #hit guikit.tmp matches 1.. run function $(fn)
