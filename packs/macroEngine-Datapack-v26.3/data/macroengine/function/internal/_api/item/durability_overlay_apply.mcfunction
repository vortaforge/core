# macroengine:internal/_api/item/durability_overlay_apply
# Internal — do not call directly. Second pass of api/item/durability_overlay.
# Expects: {player:"...",slot:"...",macroengine:{...}}

execute unless score #macroengine.open vortaforge.gate matches 1 run return 0
execute if entity @s[type=minecraft:player] unless entity @s[tag=macroengine.consented] unless score #macroengine.gate.3 vortaforge.gate matches 0 run return 0
$item modify entity @a[name=$(player),limit=1] $(slot) {function:"minecraft:set_components",components:{"minecraft:custom_data":{macroengine:$(macroengine)}}}