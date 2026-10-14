# guikit :: play/last_check   macro: $(last)
# The remembered id may point at a menu that was deleted since. Check against guikit:lib, then open.
execute unless score #guikit.open vortaforge.gate matches 1 run return 0
execute if entity @s[type=minecraft:player] unless entity @s[tag=guikit.consented] unless score #guikit.gate.3 vortaforge.gate matches 0 run return 0
$execute unless data storage guikit:lib menus.$(last) run tellraw @s {"text":"[guikit] That menu does not exist anymore.","color":"red"}
$execute unless data storage guikit:lib menus.$(last) run return 0
$function guikit:play/open_id {menu:"$(last)"}
