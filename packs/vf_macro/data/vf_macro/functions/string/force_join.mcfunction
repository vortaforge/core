# Build {"text":"","extra":[{text:p0},{text:p1},...]} on a sign — pure data modify, no string concat
# Then pulse a command block: data modify storage vf_macro:string joined_json set from block ... Text1
# joined_json is JSON source, NOT plain text. For plain Command we need another step.
#
# FORCE plain: write each part into vf_macro:string.acc using ONLY the case when
# config.force_plain is set by packing parts into one storage via iterative
# "set from" of a user-prejoined path — fallback:
# Run engine once per part ONLY if config.multi_exec=1; else error.
#
# Default multi_exec=0 → try sign path + tell user Command is in joined_json for debugging
# config.multi_exec=1 → sequential engine runs (each part must be a full command)

scoreboard players set #vf_macro.force_ok vf_macro 0

execute if data storage vf_macro:config {multi_exec:1b} run function vf_macro:string/multi_exec
execute if data storage vf_macro:config {multi_exec:1b} run scoreboard players set #vf_macro.force_ok vf_macro 1

# Build JSON extra list (works all versions) for sign
execute if score #vf_macro.force_ok vf_macro matches 0 run function vf_macro:string/build_extra
execute if score #vf_macro.force_ok vf_macro matches 0 run function vf_macro:string/sign_write
execute if score #vf_macro.force_ok vf_macro matches 0 run schedule function vf_macro:string/sign_read 2t replace
