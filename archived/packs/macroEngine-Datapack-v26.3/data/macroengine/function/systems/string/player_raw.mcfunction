# macroengine:systems/string/player_raw [MACRO]
execute if data storage macroengine:engine modules{string:0b} run return 0
$tellraw $(target) $(json)
