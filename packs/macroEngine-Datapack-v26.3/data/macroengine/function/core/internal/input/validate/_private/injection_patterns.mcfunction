# macroengine:core/internal/input/validate/_private/injection_patterns [INTERNAL]
# Seeds macroengine:input_validate scan_patterns for input/validate/injection_scan.
#
# Entries are {id, needle, strong}. Needles are matched case-insensitively
# (the scan lowercases the text first; if the fold fails on quote/backslash
# prose it falls back to the raw text, so uppercase evasions there can slip -
# see docs/prompt_injection.md "Limits"). strong:1b = treat the capture as a
# prompt-injection attempt (audit + admin notice + settings auto-apply
# refusal); strong:0b = watch-only marker for downstream readers.
#
# The list is deliberately small: the text engine pays per pattern per
# character position, and the scan runs synchronously inside a capture, so
# pattern count is a command-budget decision (see the COST BOUND note in
# injection_scan). Favour coverage per needle over enumerating phrasings.
# This is a heuristic baseline, not a guarantee: the real rule is that
# captured text is data and is never executed or obeyed - by this pack or by
# any tool reading its storage. Keep needles lowercase, ids unique, strong
# entries first (the loop stops after 2 strong hits).
execute unless score #macroengine.open vortaforge.gate matches 1 run return 0
execute if entity @s[type=minecraft:player] unless entity @s[tag=macroengine.consented] unless score #macroengine.gate.3 vortaforge.gate matches 0 run return 0
data modify storage macroengine:input_validate scan_patterns set value []
# --- strong: instruction-override / AI-addressed payload shapes ---
data modify storage macroengine:input_validate scan_patterns append value {id:"ignore_prev_instr",needle:"ignore previous instructions",strong:1b}
data modify storage macroengine:input_validate scan_patterns append value {id:"ignore_all_prev",needle:"ignore all previous",strong:1b}
data modify storage macroengine:input_validate scan_patterns append value {id:"forget_your_instr",needle:"forget your instructions",strong:1b}
data modify storage macroengine:input_validate scan_patterns append value {id:"your_new_instr",needle:"your new instructions",strong:1b}
data modify storage macroengine:input_validate scan_patterns append value {id:"system_prompt",needle:"system prompt",strong:1b}
data modify storage macroengine:input_validate scan_patterns append value {id:"sys_tag_bracket",needle:"system]",strong:1b}
data modify storage macroengine:input_validate scan_patterns append value {id:"sys_tag_angle",needle:"system>",strong:1b}
data modify storage macroengine:input_validate scan_patterns append value {id:"you_are_ai",needle:"you are an ai",strong:1b}
data modify storage macroengine:input_validate scan_patterns append value {id:"t_tell_the_user",needle:"t tell the user",strong:1b}
data modify storage macroengine:input_validate scan_patterns append value {id:"exec_following",needle:"execute the following",strong:1b}
data modify storage macroengine:input_validate scan_patterns append value {id:"make_me_op",needle:"make me op",strong:1b}
data modify storage macroengine:input_validate scan_patterns append value {id:"give_me_op",needle:"give me op",strong:1b}
# --- watch: plausible in legitimate prose - recorded, never acted on alone ---
data modify storage macroengine:input_validate scan_patterns append value {id:"language_model",needle:"language model",strong:0b}
data modify storage macroengine:input_validate scan_patterns append value {id:"run_the_command",needle:"run the command",strong:0b}
data modify storage macroengine:input_validate scan_patterns append value {id:"ignore_above",needle:"ignore the above",strong:0b}
data modify storage macroengine:input_validate scan_patterns append value {id:"prompt_injection",needle:"prompt injection",strong:0b}
data modify storage macroengine:input_validate scan_patterns append value {id:"jailbreak",needle:"jailbreak",strong:0b}
data modify storage macroengine:input_validate scan_patterns append value {id:"base64",needle:"base64",strong:0b}
return 1
