# macroengine:player/run/func_as_uuid [MACRO]
$data modify storage macroengine:engine _dispatch.func set value "$(func)"
$execute as @a[nbt={UUID:$(uuid)}] run function #macroengine:internal/dispatch
