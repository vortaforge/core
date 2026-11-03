# Private — process vf_macro:internal free_list entries
# Each entry: {key:"name", value:"Steve"}
# Builds Find="$(name)" via ostr:concat, replaces in internal.cmd

execute unless data storage vf_macro:internal free_list[0] run scoreboard players set #vf_macro.free_done vf_macro 1

execute if data storage vf_macro:internal free_list[0] run data modify storage vf_macro:internal free_item set from storage vf_macro:internal free_list[0]
execute if data storage vf_macro:internal free_list[0] run data remove storage vf_macro:internal free_list[0]

# Build Find = "$(key)"
execute if data storage vf_macro:internal free_item.key run data modify storage ostr:io in.array set value ["$(", "", ")"]
execute if data storage vf_macro:internal free_item.key run data modify storage ostr:io in.array[1] set from storage vf_macro:internal free_item.key
execute if data storage vf_macro:internal free_item.key run function ostr:concat
execute if data storage vf_macro:internal free_item.key run data modify storage vf_macro:internal find set from storage ostr:io out

# Replace in cmd
execute if data storage vf_macro:internal free_item.key run data modify storage ostr:io in.string set from storage vf_macro:internal cmd
execute if data storage vf_macro:internal free_item.key run data modify storage ostr:io in.old set from storage vf_macro:internal find
execute if data storage vf_macro:internal free_item.key run data modify storage ostr:io in.new set from storage vf_macro:internal free_item.value
execute if data storage vf_macro:internal free_item.key run function ostr:replace
execute if data storage vf_macro:internal free_item.key run data modify storage vf_macro:internal cmd set from storage ostr:io out

# Next
execute if data storage vf_macro:internal free_list[0] run function vf_macro:core/macro/replace_free
