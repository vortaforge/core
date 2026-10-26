# macroengine:internal/modules/format/_duration_words_render [MACRO]
# FIX (v26.3-r1): was an empty stub. Picks the widest non-zero unit and delegates
# to one of the four variants, producing macroengine:output text.
# The expanded numbers are first copied into real score holders: a bare number
# in "if score $(d) ..." is treated as a fake-player NAME, which never has a
# score, so the conditions would all fail.
$scoreboard players set $dw_d macroengine.tmp $(d)
$scoreboard players set $dw_h macroengine.tmp $(h)
$scoreboard players set $dw_m macroengine.tmp $(m)
execute if score $dw_d macroengine.tmp matches 1.. run function macroengine:internal/modules/format/_duration_words_render_dhm with storage macroengine:format
execute if score $dw_d macroengine.tmp matches 0 if score $dw_h macroengine.tmp matches 1.. run function macroengine:internal/modules/format/_duration_words_render_hm with storage macroengine:format
execute if score $dw_d macroengine.tmp matches 0 if score $dw_h macroengine.tmp matches 0 if score $dw_m macroengine.tmp matches 1.. run function macroengine:internal/modules/format/_duration_words_render_m with storage macroengine:format
execute if score $dw_d macroengine.tmp matches 0 if score $dw_h macroengine.tmp matches 0 if score $dw_m macroengine.tmp matches 0 run function macroengine:internal/modules/format/_duration_words_render_s with storage macroengine:format
