# macroengine:core/lib/repeat/run_as [MACRO]
$data modify storage macroengine:engine queue append value {func:"$(func)", delay:$(interval), player:"$(player)"}
