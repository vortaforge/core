# macroengine:core/internal/core/lib/schedule/reset_do_cmd [MACRO]
$data modify storage macroengine:engine schedules.$(key).cmd set value "$(cmd)"
$data modify storage macroengine:engine schedules.$(key).interval set value $(interval)
$data modify storage macroengine:engine queue append value {cmd:"$(cmd)", delay:$(interval)}
