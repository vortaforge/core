# macroengine:core/lib/for_each_player_at [MACRO]
$data modify storage macroengine:engine _dispatch.func set value "$(func)"
execute as @a at @s run function #macroengine:internal/dispatch
