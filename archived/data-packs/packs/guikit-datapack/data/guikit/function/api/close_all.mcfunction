# guikit :: api/close_all
# Closes every open guikit menu on the server at once (map resets, minigame rounds, adventure
# transitions...). Runs api/close once per owner; players without an open menu are skipped.
#
#   function guikit:api/close_all
execute unless score #guikit.open vortaforge.gate matches 1 run return 0
execute if entity @s[type=minecraft:player] unless entity @s[tag=guikit.consented] unless score #guikit.gate.3 vortaforge.gate matches 0 run return 0
execute as @a[scores={guikit.uid=1..}] run function guikit:api/close
