# guikit :: internal/sweep_orphans      (run on load; also safe to run manually)
# A cart whose owner logged off / died / lost its uid would live forever. Mark every cart,
# unmark the ones that still have an owner with the same uid, dispose the rest.
execute unless score #guikit.open vortaforge.gate matches 1 run return 0
execute if entity @s[type=minecraft:player] unless entity @s[tag=guikit.consented] unless score #guikit.gate.3 vortaforge.gate matches 0 run return 0
tag @e[type=#guikit:container,tag=guikit.cart] add guikit.orphan
execute as @a[scores={guikit.uid=1..}] run function guikit:internal/sweep/keep
execute as @e[type=#guikit:container,tag=guikit.cart,tag=guikit.orphan] run function guikit:internal/pad/dispose_cart
execute as @e[type=minecraft:interaction,tag=guikit.guard] run function guikit:internal/guard/orphan
