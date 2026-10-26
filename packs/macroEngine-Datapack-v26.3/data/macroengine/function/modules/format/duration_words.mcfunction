# macroengine:modules/format/duration_words
# INPUT: $(ticks)
# OUTPUT storage macroengine:output {days,hours,minutes,seconds,text}
execute unless score #macroengine.open vortaforge.gate matches 1 run return 0
execute if entity @s[type=minecraft:player] unless entity @s[tag=macroengine.consented] unless score #macroengine.gate.3 vortaforge.gate matches 0 run return 0

$scoreboard players set $fd_t macroengine.tmp $(ticks)
execute if score $fd_t macroengine.tmp matches ..-1 run scoreboard players set $fd_t macroengine.tmp 0

scoreboard players set $fd_20 macroengine.tmp 20
scoreboard players operation $fd_s macroengine.tmp = $fd_t macroengine.tmp
scoreboard players operation $fd_s macroengine.tmp /= $fd_20 macroengine.tmp

scoreboard players set $fd_60 macroengine.tmp 60
scoreboard players operation $fd_m macroengine.tmp = $fd_s macroengine.tmp
scoreboard players operation $fd_m macroengine.tmp /= $fd_60 macroengine.tmp
scoreboard players operation $fd_s macroengine.tmp %= $fd_60 macroengine.tmp

scoreboard players operation $fd_h macroengine.tmp = $fd_m macroengine.tmp
scoreboard players operation $fd_h macroengine.tmp /= $fd_60 macroengine.tmp
scoreboard players operation $fd_m macroengine.tmp %= $fd_60 macroengine.tmp

scoreboard players set $fd_24 macroengine.tmp 24
scoreboard players operation $fd_d macroengine.tmp = $fd_h macroengine.tmp
scoreboard players operation $fd_d macroengine.tmp /= $fd_24 macroengine.tmp
scoreboard players operation $fd_h macroengine.tmp %= $fd_24 macroengine.tmp

execute store result storage macroengine:output days int 1 run scoreboard players get $fd_d macroengine.tmp
execute store result storage macroengine:output hours int 1 run scoreboard players get $fd_h macroengine.tmp
execute store result storage macroengine:output minutes int 1 run scoreboard players get $fd_m macroengine.tmp
execute store result storage macroengine:output seconds int 1 run scoreboard players get $fd_s macroengine.tmp

# FIX (v26.3-r1): hand the parts to the renderer. The four
# internal/modules/format/_duration_words_render* functions were comment-only
# stubs, so the documented `text` output was never produced.
execute store result storage macroengine:format d int 1 run scoreboard players get $fd_d macroengine.tmp
execute store result storage macroengine:format h int 1 run scoreboard players get $fd_h macroengine.tmp
execute store result storage macroengine:format m int 1 run scoreboard players get $fd_m macroengine.tmp
execute store result storage macroengine:format s int 1 run scoreboard players get $fd_s macroengine.tmp
function macroengine:internal/modules/format/_duration_words_render with storage macroengine:format

