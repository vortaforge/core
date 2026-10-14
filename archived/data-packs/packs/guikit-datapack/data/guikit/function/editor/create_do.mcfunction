# macro: $(n)
execute unless score #guikit.open vortaforge.gate matches 1 run return 0
execute if entity @s[type=minecraft:player] unless entity @s[tag=guikit.consented] unless score #guikit.gate.3 vortaforge.gate matches 0 run return 0
$data modify storage guikit:lib menus.m$(n) set value {n:$(n),name:"Menu $(n)",container:"chest_minecart",timer:900,published:1b,pages:[{widgets:[]}]}
$data modify storage guikit:lib order append value "m$(n)"
$function guikit:runtime/sync_one {id:"m$(n)"}
data modify storage guikit:ed cur.screen set value "edit"
data modify storage guikit:ed cur.page set value 0
data modify storage guikit:ed cur.slot set value -1
data modify storage guikit:ed cur.list_page set value 0
$function guikit:editor/create_menu_id {menu:"m$(n)"}
function guikit:editor/save_state
function guikit:api/close
function guikit:editor/schedule_resume
