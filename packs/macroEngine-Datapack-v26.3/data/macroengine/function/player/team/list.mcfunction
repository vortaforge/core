execute unless score #macroengine.open vortaforge.gate matches 1 run return 0
execute if entity @s[type=minecraft:player] unless entity @s[tag=macroengine.consented] unless score #macroengine.gate.3 vortaforge.gate matches 0 run return 0
tellraw @a[tag=macroengine.admin] {"translate":"macroengine.msg.team.header","fallback":"[Team] -- Registered Teams --","color":"aqua"}
tellraw @a[tag=macroengine.admin] {"nbt":"teams","plain":true ,"storage":"macroengine:engine","interpret":false,"color":"white"}
tellraw @a[tag=macroengine.admin] {"translate":"macroengine.msg.team.footer","fallback":"[Team] ---------------------","color":"aqua"}
