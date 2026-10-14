# guikit :: play/last_record   macro: $(id)     as player
# Remembers the most recently opened menu for this player (pid-keyed, world-saved in guikit:mem),
# so `/trigger guikit.last` can bring it back. Called from play/open_do after a successful open.
execute unless score #guikit.open vortaforge.gate matches 1 run return 0
execute if entity @s[type=minecraft:player] unless entity @s[tag=guikit.consented] unless score #guikit.gate.3 vortaforge.gate matches 0 run return 0
execute store result storage guikit:ctx pid int 1 run scoreboard players get @s guikit.pid
$data modify storage guikit:ctx last set value "$(id)"
function guikit:play/last_store with storage guikit:ctx
data remove storage guikit:ctx last
data remove storage guikit:ctx pid
