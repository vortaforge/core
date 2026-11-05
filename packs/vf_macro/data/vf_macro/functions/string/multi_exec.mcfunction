# Each resolved string is a FULL command — run sequentially via schedule
data modify storage vf_macro:string exec_list set from storage vf_macro:string parts
function vf_macro:string/multi_exec_step
