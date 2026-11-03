# Private — replace one placeholder in vf_macro:internal cmd using ostr:replace
# Expects:
#   vf_macro:internal find  = "$(name)" etc
#   vf_macro:internal arg   = key name in args (e.g. "name")
# Value is read from vf_macro:args.<arg>

data modify storage ostr:io in.string set from storage vf_macro:internal cmd
data modify storage ostr:io in.old set from storage vf_macro:internal find

# Copy replacement value based on arg name
data modify storage ostr:io in.new set value ""
execute if data storage vf_macro:internal {arg:"name"} run data modify storage ostr:io in.new set from storage vf_macro:args name
execute if data storage vf_macro:internal {arg:"amount"} run data modify storage ostr:io in.new set from storage vf_macro:args amount
execute if data storage vf_macro:internal {arg:"value"} run data modify storage ostr:io in.new set from storage vf_macro:args value
execute if data storage vf_macro:internal {arg:"player"} run data modify storage ostr:io in.new set from storage vf_macro:args player
execute if data storage vf_macro:internal {arg:"id"} run data modify storage ostr:io in.new set from storage vf_macro:args id
execute if data storage vf_macro:internal {arg:"x"} run data modify storage ostr:io in.new set from storage vf_macro:args x
execute if data storage vf_macro:internal {arg:"y"} run data modify storage ostr:io in.new set from storage vf_macro:args y
execute if data storage vf_macro:internal {arg:"z"} run data modify storage ostr:io in.new set from storage vf_macro:args z
execute if data storage vf_macro:internal {arg:"pos"} run data modify storage ostr:io in.new set from storage vf_macro:args pos
execute if data storage vf_macro:internal {arg:"cmd"} run data modify storage ostr:io in.new set from storage vf_macro:args cmd
execute if data storage vf_macro:internal {arg:"func"} run data modify storage ostr:io in.new set from storage vf_macro:args func
execute if data storage vf_macro:internal {arg:"msg"} run data modify storage ostr:io in.new set from storage vf_macro:args msg
execute if data storage vf_macro:internal {arg:"text"} run data modify storage ostr:io in.new set from storage vf_macro:args text
execute if data storage vf_macro:internal {arg:"count"} run data modify storage ostr:io in.new set from storage vf_macro:args count
execute if data storage vf_macro:internal {arg:"score"} run data modify storage ostr:io in.new set from storage vf_macro:args score
execute if data storage vf_macro:internal {arg:"target"} run data modify storage ostr:io in.new set from storage vf_macro:args target
execute if data storage vf_macro:internal {arg:"selector"} run data modify storage ostr:io in.new set from storage vf_macro:args selector
execute if data storage vf_macro:internal {arg:"path"} run data modify storage ostr:io in.new set from storage vf_macro:args path
execute if data storage vf_macro:internal {arg:"storage"} run data modify storage ostr:io in.new set from storage vf_macro:args storage
execute if data storage vf_macro:internal {arg:"key"} run data modify storage ostr:io in.new set from storage vf_macro:args key

function ostr:replace
data modify storage vf_macro:internal cmd set from storage ostr:io out
