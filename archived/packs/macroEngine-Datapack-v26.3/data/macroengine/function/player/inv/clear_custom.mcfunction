# macroengine:player/inv/clear_custom [MACRO]
$execute as @a[name=$(player),limit=1] run clear @s $(item)[minecraft:custom_data=$(custom_data)] $(count)
