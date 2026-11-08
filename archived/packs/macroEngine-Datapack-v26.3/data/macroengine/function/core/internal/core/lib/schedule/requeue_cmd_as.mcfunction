# macroengine:core/internal/core/lib/schedule/requeue_cmd_as [MACRO]
$data modify storage macroengine:engine queue append value {cmd:"$(cmd)", delay:$(interval), player:"$(player)"}
