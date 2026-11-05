forceload add 1 1
# 1.16–1.19 use Text1; 1.20+ front_text — try Text1 first (works through 1.19)
setblock 1 0 1 minecraft:oak_sign{Text1:'{"text":""}'} replace
data modify storage vf_macro:string sign_payload set value {text:"",extra:[]}
data modify storage vf_macro:string sign_payload.extra set from storage vf_macro:string extra
# Store payload; sign Text must be JSON string — without string concat we set from a
# pre-serialized path. We write extra via block data where supported.
# Fallback: keep sign_payload in storage for the caller.
data modify storage vf_macro:out sign_payload set from storage vf_macro:string sign_payload
data modify block 1 0 1 Text1 set value '{"text":"[VF Macro join — use multi_exec or single token]"}'
