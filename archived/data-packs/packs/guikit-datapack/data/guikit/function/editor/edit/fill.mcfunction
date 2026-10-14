# guikit :: editor/edit/fill     as player
# No auto-refresh here: replacing the editor chest every second fights the click.
execute unless score #guikit.open vortaforge.gate matches 1 run return 0
execute if entity @s[type=minecraft:player] unless entity @s[tag=guikit.consented] unless score #guikit.gate.3 vortaforge.gate matches 0 run return 0
function guikit:editor/load_state
scoreboard players set @s guikit.rfiv 0
function guikit:editor/read_menu
function guikit:widget/pad
scoreboard players set #limit guikit.tmp 27
execute if data storage guikit:work menu{container:"hopper_minecart"} run scoreboard players set #limit guikit.tmp 5
execute store result storage guikit:work page int 1 run data get storage guikit:ed cur.page
function guikit:editor/edit/load_page with storage guikit:work
scoreboard players set #i guikit.tmp 0
function guikit:editor/edit/placeholders
function guikit:editor/edit/draw_loop
function guikit:editor/edit/tools_button
