# macroengine:player/team/set_friendly_fire [MACRO]
$team modify $(team) friendlyFire $(value)
$data modify storage macroengine:engine teams.$(team).friendly_fire set value "$(value)"
