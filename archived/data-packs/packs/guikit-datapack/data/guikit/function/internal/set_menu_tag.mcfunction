# macro: $(menu)
# Player tag "guikit.m.<alias>" lets fill/probe routers dispatch per menu.
# Tags cannot contain ':' or '/', so menus register a tag-safe `alias`.
execute unless score #guikit.open vortaforge.gate matches 1 run return 0
execute if entity @s[type=minecraft:player] unless entity @s[tag=guikit.consented] unless score #guikit.gate.3 vortaforge.gate matches 0 run return 0
$data modify storage guikit:ctx alias set from storage guikit:reg menus."$(menu)".alias
function guikit:internal/set_alias_tag with storage guikit:ctx
