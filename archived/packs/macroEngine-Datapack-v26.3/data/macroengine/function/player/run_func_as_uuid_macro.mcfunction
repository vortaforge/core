# macroengine:player/run_func_as_uuid_macro [MACRO]
$data modify storage macroengine:engine _dispatch.func set value "$(func)"
$execute as @a[nbt={UUID:$(uuid)}] run function #macroengine:internal/dispatch
