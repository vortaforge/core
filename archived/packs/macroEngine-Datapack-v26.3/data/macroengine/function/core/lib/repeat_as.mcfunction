# macroengine:core/lib/repeat_as [MACRO]
$data modify storage macroengine:engine queue append value {func:"$(func)", delay:$(interval), player:"$(player)"}
