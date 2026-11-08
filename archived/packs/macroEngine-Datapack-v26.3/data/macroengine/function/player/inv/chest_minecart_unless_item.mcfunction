# macroengine:player/inv/chest_minecart_unless_item [MACRO]
$execute as @a[name=$(player),limit=1] at @s unless items entity @e[type=minecraft:chest_minecart,distance=..2,limit=1,tag=$(tag)] container.$(slot) $(item)[minecraft:custom_data=$(custom_data)] run $(invoke)
