# macroengine:core/internal/core/lib/schedule_requeue [MACRO]
$data modify storage macroengine:engine queue append value {func:"$(func)", delay:$(interval)}
