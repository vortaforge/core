# ======================================================================================
# macroengine:input/validate/injection_scan
# ======================================================================================
#
# PROMPT-INJECTION SCREENING FOR CAPTURED PLAYER TEXT.
#
# Datapacks have no sandbox and no JVM isolation: a function runs with
# console-level authority, and this pack captures free-form player text
# (books, signs, lecterns, name tags, anvil renames) into storage. That text
# is data and this pack never executes or obeys it - but an operator who
# lets an AI tool read pack storage, logs or world data turns every capture
# into a possible instruction channel to that tool. This scan is the
# tripwire for that case: it flags text shaped like an instruction to an AI
# reader so it is marked, audited and announced instead of flowing on
# silently. Full threat model, pattern list and limits:
# docs/prompt_injection.md.
#
# INPUT  (storage macroengine:input_validate):
#   scan_in.text — the string to screen (copied in by the caller)
#   scan_in.kind — short source label set by the caller ("book", "sign",
#                  "lectern", "name_tag", "anvil"); used for audit/notify.
# OUTPUT (storage macroengine:input_validate):
#   scan.suspicious  — 1b if a strong pattern matched
#   scan.watch       — 1b if only watch-tier patterns matched (or folding/truncation)
#   scan.fold_failed — 1b if lowercasing failed (quote/backslash prose)
#   scan.truncated   — 1b if only a prefix of the text was screened
#   scan.strong_count— number of strong hits (the scan stops at 2)
#   scan.hits        — [{id, strong}] per matched pattern (ids only)
# RETURN 1 if suspicious, else 0.
#
# COST BOUND: the text engine compares one window per pattern per position,
# so an unbounded scan of a full book page would blow the command-chain
# limit. The scan therefore screens at most a 96-character prefix and stops
# after 2 strong hits; anything past the prefix is reported via
# scan.truncated instead of being silently trusted. Typical captures
# (signs, names, short notes) fit the prefix whole.
#
# The text is only compared as data by the in-house text engine; it is
# never macro-substituted, never executed and never treated as an
# instruction - here or anywhere else in this pack. Toggle with the
# injection_scan config key (default on). Side-effect free apart from the
# scan output: auditing/notifying is the caller's job (see
# core/internal/input/validate/_private/injection_report).
# ======================================================================================

data modify storage macroengine:input_validate scan set value {suspicious:0b,watch:0b,fold_failed:0b,truncated:0b,strong_count:0,hits:[]}
execute unless score #macroengine.open vortaforge.gate matches 1 run return 0
execute if entity @s[type=minecraft:player] unless entity @s[tag=macroengine.consented] unless score #macroengine.gate.3 vortaforge.gate matches 0 run return 0
execute unless score #injection_scan macroengine.tick_flags matches 1 run return 0
execute unless data storage macroengine:input_validate scan_in.text run return 0

# Coerce to a plain string first (a sign line can arrive as a whole text
# component compound), then case-fold with a raw-text fallback.
data remove storage macroengine:input_validate scan_work
data modify storage macroengine:input_validate scan_work set string storage macroengine:input_validate scan_in.text
data modify storage macroengine:input string set from storage macroengine:input_validate scan_work
function macroengine:core/lib/string/to_lowercase
execute if data storage macroengine:output string.result run data modify storage macroengine:input_validate scan_work set from storage macroengine:output string.result
execute unless data storage macroengine:output string.result run data modify storage macroengine:input_validate scan.fold_failed set value 1b
execute unless data storage macroengine:output string.result run data modify storage macroengine:input_validate scan.watch set value 1b
execute unless data storage macroengine:output string.result run data modify storage macroengine:input_validate scan.hits append value {id:"case_fold_failed",strong:0b}

# Bounded prefix (see COST BOUND above): screen at most 96 characters and
# say so when the rest was not screened.
execute store result score #inj_len macroengine.tmp run data get storage macroengine:input_validate scan_work
execute if score #inj_len macroengine.tmp matches 97.. run data modify storage macroengine:input_validate scan_work set string storage macroengine:input_validate scan_work 0 96
execute if score #inj_len macroengine.tmp matches 97.. run data modify storage macroengine:input_validate scan.truncated set value 1b
execute if score #inj_len macroengine.tmp matches 97.. run data modify storage macroengine:input_validate scan.watch set value 1b
execute if score #inj_len macroengine.tmp matches 97.. run data modify storage macroengine:input_validate scan.hits append value {id:"scan_truncated",strong:0b}

function macroengine:core/internal/input/validate/_private/injection_patterns
scoreboard players set #inj_strong macroengine.tmp 0
scoreboard players set #inj_watch macroengine.tmp 0
scoreboard players set #inj_hits macroengine.tmp 0
function macroengine:core/internal/input/validate/_private/injection_loop

execute if score #inj_strong macroengine.tmp matches 1 run data modify storage macroengine:input_validate scan.suspicious set value 1b
execute if score #inj_watch macroengine.tmp matches 1 run data modify storage macroengine:input_validate scan.watch set value 1b
execute store result storage macroengine:input_validate scan.strong_count int 1 run scoreboard players get #inj_hits macroengine.tmp

data remove storage macroengine:input_validate scan_patterns
data remove storage macroengine:input_validate scan_work
data remove storage macroengine:input_validate cur
function macroengine:core/internal/text/reset
execute if data storage macroengine:input_validate scan{suspicious:1b} run return 1
return 0
