# Private — sequential $(key) replace via ostr

execute unless data storage vf_macro:internal present_keys[0] run data modify storage vf_macro:out note set value "placeholder replace done via ostr"

execute if data storage vf_macro:internal present_keys[0] run data modify storage vf_macro:internal cur_key set from storage vf_macro:internal present_keys[0]
execute if data storage vf_macro:internal present_keys[0] run data remove storage vf_macro:internal present_keys[0]

execute if data storage vf_macro:internal {cur_key:"name"} run data modify storage vf_macro:internal find set value "$(name)"
execute if data storage vf_macro:internal {cur_key:"name"} run data modify storage vf_macro:internal arg set value "name"
execute if data storage vf_macro:internal {cur_key:"name"} run function vf_macro:core/macro/replace_one

execute if data storage vf_macro:internal {cur_key:"amount"} run data modify storage vf_macro:internal find set value "$(amount)"
execute if data storage vf_macro:internal {cur_key:"amount"} run data modify storage vf_macro:internal arg set value "amount"
execute if data storage vf_macro:internal {cur_key:"amount"} run function vf_macro:core/macro/replace_one

execute if data storage vf_macro:internal {cur_key:"value"} run data modify storage vf_macro:internal find set value "$(value)"
execute if data storage vf_macro:internal {cur_key:"value"} run data modify storage vf_macro:internal arg set value "value"
execute if data storage vf_macro:internal {cur_key:"value"} run function vf_macro:core/macro/replace_one

execute if data storage vf_macro:internal {cur_key:"player"} run data modify storage vf_macro:internal find set value "$(player)"
execute if data storage vf_macro:internal {cur_key:"player"} run data modify storage vf_macro:internal arg set value "player"
execute if data storage vf_macro:internal {cur_key:"player"} run function vf_macro:core/macro/replace_one

execute if data storage vf_macro:internal {cur_key:"id"} run data modify storage vf_macro:internal find set value "$(id)"
execute if data storage vf_macro:internal {cur_key:"id"} run data modify storage vf_macro:internal arg set value "id"
execute if data storage vf_macro:internal {cur_key:"id"} run function vf_macro:core/macro/replace_one

execute if data storage vf_macro:internal {cur_key:"x"} run data modify storage vf_macro:internal find set value "$(x)"
execute if data storage vf_macro:internal {cur_key:"x"} run data modify storage vf_macro:internal arg set value "x"
execute if data storage vf_macro:internal {cur_key:"x"} run function vf_macro:core/macro/replace_one

execute if data storage vf_macro:internal {cur_key:"y"} run data modify storage vf_macro:internal find set value "$(y)"
execute if data storage vf_macro:internal {cur_key:"y"} run data modify storage vf_macro:internal arg set value "y"
execute if data storage vf_macro:internal {cur_key:"y"} run function vf_macro:core/macro/replace_one

execute if data storage vf_macro:internal {cur_key:"z"} run data modify storage vf_macro:internal find set value "$(z)"
execute if data storage vf_macro:internal {cur_key:"z"} run data modify storage vf_macro:internal arg set value "z"
execute if data storage vf_macro:internal {cur_key:"z"} run function vf_macro:core/macro/replace_one

execute if data storage vf_macro:internal {cur_key:"pos"} run data modify storage vf_macro:internal find set value "$(pos)"
execute if data storage vf_macro:internal {cur_key:"pos"} run data modify storage vf_macro:internal arg set value "pos"
execute if data storage vf_macro:internal {cur_key:"pos"} run function vf_macro:core/macro/replace_one

execute if data storage vf_macro:internal {cur_key:"cmd"} run data modify storage vf_macro:internal find set value "$(cmd)"
execute if data storage vf_macro:internal {cur_key:"cmd"} run data modify storage vf_macro:internal arg set value "cmd"
execute if data storage vf_macro:internal {cur_key:"cmd"} run function vf_macro:core/macro/replace_one

execute if data storage vf_macro:internal {cur_key:"func"} run data modify storage vf_macro:internal find set value "$(func)"
execute if data storage vf_macro:internal {cur_key:"func"} run data modify storage vf_macro:internal arg set value "func"
execute if data storage vf_macro:internal {cur_key:"func"} run function vf_macro:core/macro/replace_one

execute if data storage vf_macro:internal {cur_key:"msg"} run data modify storage vf_macro:internal find set value "$(msg)"
execute if data storage vf_macro:internal {cur_key:"msg"} run data modify storage vf_macro:internal arg set value "msg"
execute if data storage vf_macro:internal {cur_key:"msg"} run function vf_macro:core/macro/replace_one

execute if data storage vf_macro:internal {cur_key:"text"} run data modify storage vf_macro:internal find set value "$(text)"
execute if data storage vf_macro:internal {cur_key:"text"} run data modify storage vf_macro:internal arg set value "text"
execute if data storage vf_macro:internal {cur_key:"text"} run function vf_macro:core/macro/replace_one

execute if data storage vf_macro:internal {cur_key:"count"} run data modify storage vf_macro:internal find set value "$(count)"
execute if data storage vf_macro:internal {cur_key:"count"} run data modify storage vf_macro:internal arg set value "count"
execute if data storage vf_macro:internal {cur_key:"count"} run function vf_macro:core/macro/replace_one

execute if data storage vf_macro:internal {cur_key:"score"} run data modify storage vf_macro:internal find set value "$(score)"
execute if data storage vf_macro:internal {cur_key:"score"} run data modify storage vf_macro:internal arg set value "score"
execute if data storage vf_macro:internal {cur_key:"score"} run function vf_macro:core/macro/replace_one

execute if data storage vf_macro:internal {cur_key:"target"} run data modify storage vf_macro:internal find set value "$(target)"
execute if data storage vf_macro:internal {cur_key:"target"} run data modify storage vf_macro:internal arg set value "target"
execute if data storage vf_macro:internal {cur_key:"target"} run function vf_macro:core/macro/replace_one

execute if data storage vf_macro:internal {cur_key:"selector"} run data modify storage vf_macro:internal find set value "$(selector)"
execute if data storage vf_macro:internal {cur_key:"selector"} run data modify storage vf_macro:internal arg set value "selector"
execute if data storage vf_macro:internal {cur_key:"selector"} run function vf_macro:core/macro/replace_one

execute if data storage vf_macro:internal {cur_key:"path"} run data modify storage vf_macro:internal find set value "$(path)"
execute if data storage vf_macro:internal {cur_key:"path"} run data modify storage vf_macro:internal arg set value "path"
execute if data storage vf_macro:internal {cur_key:"path"} run function vf_macro:core/macro/replace_one

execute if data storage vf_macro:internal {cur_key:"storage"} run data modify storage vf_macro:internal find set value "$(storage)"
execute if data storage vf_macro:internal {cur_key:"storage"} run data modify storage vf_macro:internal arg set value "storage"
execute if data storage vf_macro:internal {cur_key:"storage"} run function vf_macro:core/macro/replace_one

execute if data storage vf_macro:internal {cur_key:"key"} run data modify storage vf_macro:internal find set value "$(key)"
execute if data storage vf_macro:internal {cur_key:"key"} run data modify storage vf_macro:internal arg set value "key"
execute if data storage vf_macro:internal {cur_key:"key"} run function vf_macro:core/macro/replace_one

execute if data storage vf_macro:internal present_keys[0] run function vf_macro:core/macro/replace_keys
