# macroengine:core/lib/for_each/player [MACRO]
$data modify storage macroengine:engine _dispatch.func set value "$(func)"
execute as @a run function #macroengine:internal/dispatch
