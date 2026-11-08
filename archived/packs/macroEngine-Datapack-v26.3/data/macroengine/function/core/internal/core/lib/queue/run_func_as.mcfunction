# macroengine:core/internal/core/lib/queue/run_func_as [MACRO]
$data modify storage macroengine:engine _dispatch.func set value "$(func)"
$execute as $(player) at @s run function #macroengine:internal/dispatch
