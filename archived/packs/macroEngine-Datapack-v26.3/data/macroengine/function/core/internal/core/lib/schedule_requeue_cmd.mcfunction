# macroengine:core/internal/core/lib/schedule_requeue_cmd [MACRO]
$data modify storage macroengine:engine queue append value {cmd:"$(cmd)", delay:$(interval)}
