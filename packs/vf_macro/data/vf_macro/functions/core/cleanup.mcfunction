# Private — clear all temporary macro-resolution state
# Must be called at the end of every public API entry point
# (api/macro/parts, api/macro/template, api/macro/with_storage)
# so a new call never sees leftover data from the previous one.
#
# vf_macro:args and vf_macro:config are intentionally NOT cleared here:
# args is caller-owned input, config is persistent settings.
#
# Scores intentionally NOT reset here:
#   #vf_macro.version      — fixed config, set once in core/load
#   #vf_macro.returned     — result flag the caller reads after this call
#   #vf_macro.if_success   — result flag api/if_function/run produces for the caller
#   #vf_macro.return_value — may be caller-supplied input (api/return/value fallback)

data remove storage vf_macro:internal cur_key
data remove storage vf_macro:internal current
data remove storage vf_macro:internal free_item
data remove storage vf_macro:internal resolve_list
data remove storage vf_macro:internal find
data remove storage vf_macro:internal arg
data remove storage vf_macro:internal free_list
data remove storage vf_macro:internal keyname
data remove storage vf_macro:internal cmd
data remove storage vf_macro:internal present_keys

data remove storage vf_macro:in template
data remove storage vf_macro:in replace_list
data remove storage vf_macro:in source
data remove storage vf_macro:in parts
data remove storage vf_macro:in Command
data remove storage vf_macro:in value
data remove storage vf_macro:in data

data remove storage vf_macro:engine Command

data remove storage vf_macro:out template
data remove storage vf_macro:out args
data remove storage vf_macro:out note
data remove storage vf_macro:out present_keys
data remove storage vf_macro:out Command
data remove storage vf_macro:out resolved_full
data remove storage vf_macro:out cleared
data remove storage vf_macro:out join_note
data remove storage vf_macro:out resolved

data remove storage ostr:io in
data remove storage ostr:io out
data remove storage ostr:data temp

scoreboard players set #vf_macro.skip vf_macro 0
scoreboard players set #vf_macro.free_done vf_macro 0
scoreboard players set #vf_macro.key_found vf_macro 0
scoreboard players set #vf_macro.resolve_done vf_macro 0
