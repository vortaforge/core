# macroengine:core/internal/core/lib/schedule/requeue [MACRO]
$data modify storage macroengine:engine queue append value {func:"$(func)", delay:$(interval)}
