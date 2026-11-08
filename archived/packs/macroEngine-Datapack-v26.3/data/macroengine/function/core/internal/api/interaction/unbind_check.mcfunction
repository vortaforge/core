# macroengine:core/internal/api/interaction/unbind_check [MACRO]
$execute unless data storage macroengine:engine _ia_ucur{tag:"$(tag)",func:"$(func)"} run data modify storage macroengine:engine interaction_binds.$(list) append from storage macroengine:engine _ia_ucur
