# macroengine:core/lib/wait/cmd_as [MACRO]
$data modify storage macroengine:engine queue append value {cmd:"$(cmd)", delay:$(delay), player:"$(player)"}
