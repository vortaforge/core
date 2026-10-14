# guikit :: runtime/sync_container     build cdef from the saved menu (name copied as NBT, not re-macro'd)
execute unless score #guikit.open vortaforge.gate matches 1 run return 0
execute if entity @s[type=minecraft:player] unless entity @s[tag=guikit.consented] unless score #guikit.gate.3 vortaforge.gate matches 0 run return 0
data modify storage guikit:work cdef set value {entity:"chest_minecart",slots:27,pad:"minecraft:gray_stained_glass_pane"}
execute if data storage guikit:work menu{container:"hopper_minecart"} run data modify storage guikit:work cdef set value {entity:"hopper_minecart",slots:5,pad:"minecraft:gray_stained_glass_pane"}
execute if data storage guikit:work menu{container:"barrel"} run data modify storage guikit:work cdef set value {entity:"chest_minecart",slots:27,pad:"minecraft:brown_stained_glass_pane"}
execute if data storage guikit:work menu{container:"ender_chest"} run data modify storage guikit:work cdef set value {entity:"chest_minecart",slots:27,pad:"minecraft:purple_stained_glass_pane"}
execute if data storage guikit:work menu{container:"trapped_chest"} run data modify storage guikit:work cdef set value {entity:"chest_minecart",slots:27,pad:"minecraft:red_stained_glass_pane"}
execute if data storage guikit:work menu{container:"shulker_box"} run data modify storage guikit:work cdef set value {entity:"chest_minecart",slots:27,pad:"minecraft:magenta_stained_glass_pane"}
execute if data storage guikit:work menu{container:"copper_chest"} run data modify storage guikit:work cdef set value {entity:"chest_minecart",slots:27,pad:"minecraft:orange_stained_glass_pane"}
data modify storage guikit:work cdef.title set value {text:"Menu",italic:false}
data modify storage guikit:work cdef.title.text set from storage guikit:work menu.name
