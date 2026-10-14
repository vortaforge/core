# macro: $(menu)     menu id is m<number>
execute unless score #guikit.open vortaforge.gate matches 1 run return 0
execute if entity @s[type=minecraft:player] unless entity @s[tag=guikit.consented] unless score #guikit.gate.3 vortaforge.gate matches 0 run return 0
function guikit:runtime/ensure_pid
$function guikit:play/open_do {id:"$(menu)"}
