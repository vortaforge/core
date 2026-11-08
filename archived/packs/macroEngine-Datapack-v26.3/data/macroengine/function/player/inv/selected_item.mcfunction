# macroengine:player/inv/selected_item [MACRO]
$execute as @a[name=$(player),limit=1] as @a at @s if items entity @s weapon.mainhand $(item)[minecraft:custom_data=$(custom_data)] run $(invoke)
