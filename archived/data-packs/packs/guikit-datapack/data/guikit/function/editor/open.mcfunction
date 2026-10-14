# guikit :: editor/open     /function guikit:editor/open  (permission level 2)
execute unless score #guikit.open vortaforge.gate matches 1 run return 0
execute if entity @s[type=minecraft:player] unless entity @s[tag=guikit.consented] unless score #guikit.gate.3 vortaforge.gate matches 0 run return 0
function guikit:runtime/ensure_pid
function guikit:editor/load_state
data modify storage guikit:ed cur.screen set value "home"
function guikit:editor/save_state
function guikit:editor/open_home
