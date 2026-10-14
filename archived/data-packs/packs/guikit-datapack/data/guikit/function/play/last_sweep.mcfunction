# guikit :: play/last_sweep     walks every pid slot in guikit:mem last and drops entries that
# point at the menu currently being deleted (storage guikit:work gone / guikit:ctx gone).
# One slot per recursion step; the loop stops when #mi passes the highest pid ever handed out.
execute unless score #guikit.open vortaforge.gate matches 1 run return 0
execute if entity @s[type=minecraft:player] unless entity @s[tag=guikit.consented] unless score #guikit.gate.3 vortaforge.gate matches 0 run return 0
execute unless score #mi guikit.tmp <= #mn guikit.tmp run return 0
execute store result storage guikit:ctx pid int 1 run scoreboard players get #mi guikit.tmp
function guikit:play/last_sweep_one with storage guikit:ctx
scoreboard players add #mi guikit.tmp 1
function guikit:play/last_sweep
