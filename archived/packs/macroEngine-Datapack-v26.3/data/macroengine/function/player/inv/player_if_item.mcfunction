# macroengine:player/inv/player_if_item [MACRO]
$execute as @a[name=$(player),limit=1] at @s if items entity @s contents $(item)[minecraft:custom_data=$(custom_data)] run $(invoke)
