# Private — write command into the block and pulse it

# Clear previous
data modify block 0 -64 0 Command set value ""
data modify block 0 -64 0 auto set value 0b

# Write command from storage
data modify block 0 -64 0 Command set from storage vf_macro:engine Command
data modify block 0 -64 0 auto set value 1b

# Optional: keep LastOutput for debugging
execute if data storage vf_macro:config {track_output:1b} run data modify block 0 -64 0 TrackOutput set value 1b

# Schedule cleanup
schedule function vf_macro:core/engine/reset 3t replace
