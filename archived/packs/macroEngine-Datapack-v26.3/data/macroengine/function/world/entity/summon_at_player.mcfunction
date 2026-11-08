# macroengine:world/entity/summon_at_player [MACRO]
$execute as @a[name=$(player),limit=1] at @s run summon $(entity) ~ ~ ~ $(nbt)
