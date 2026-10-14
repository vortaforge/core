# guikit :: widget/sound   as player, at player   storage guikit:in {sound:"minecraft:ui.button.click", [volume:1.0], [pitch:1.0]}
# Plays a sound to the player (audible only to them). Call it from a click handler for feedback.
# `sound` is required; volume defaults to 1.0, pitch to 1.0. Does NOT mark the menu dirty.
# `sound` must come from your menu code, never from player input (it is macro-expanded raw).
execute unless score #guikit.open vortaforge.gate matches 1 run return 0
execute if entity @s[type=minecraft:player] unless entity @s[tag=guikit.consented] unless score #guikit.gate.3 vortaforge.gate matches 0 run return 0
execute unless data storage guikit:in sound run return 0
execute unless data storage guikit:in volume run data modify storage guikit:in volume set value 1.0
execute unless data storage guikit:in pitch run data modify storage guikit:in pitch set value 1.0
function guikit:internal/sound_play with storage guikit:in
