# macroengine:player/team/set_color [MACRO]
$team modify $(team) color $(color)
$data modify storage macroengine:engine teams.$(team).color set value "$(color)"
