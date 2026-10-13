// AI-assisted: written by Claude (Anthropic) for the packweld project (see CREDITS.md).

const props=new Map(); let tick=0; const timers=[]; const sent=[];
class Player{constructor(n){this.name=n;this.typeId="minecraft:player";this.tags=new Set();this.props=new Map();this.location={x:1.5,y:64.2,z:-3.7};this.dimension={id:"minecraft:overworld"};this.isSneaking=false;this.onScreenDisplay={setTitle:(t,o)=>sent.push(["title",t,o]),setActionBar:(t)=>sent.push(["bar",t])};this.cmds=[]}
 sendMessage(m){sent.push(["msg",this.name,m])} addTag(t){this.tags.add(t);return true} removeTag(t){return this.tags.delete(t)} hasTag(t){return this.tags.has(t)} getTags(){return [...this.tags]}
 getDynamicProperty(k){return this.props.get(k)} setDynamicProperty(k,v){v===undefined?this.props.delete(k):this.props.set(k,v)} getDynamicPropertyIds(){return [...this.props.keys()]}
 runCommand(c){this.cmds.push(c);return {successCount:1}} getComponent(){return {currentValue:20}} playSound(){}}
const players=[new Player("Steve"),new Player("Alex")];
export const world={getPlayers:(o)=>players.filter(p=>!o||!o.name||p.name===o.name),getAllPlayers:()=>players,sendMessage:(m)=>sent.push(["world",m]),
 getDynamicProperty:(k)=>props.get(k),setDynamicProperty:(k,v)=>v===undefined?props.delete(k):props.set(k,v),getDynamicPropertyIds:()=>[...props.keys()],
 getDimension:()=>({runCommand:(c)=>({successCount:1,c})}),scoreboard:{getObjective:()=>({getScore:()=>5})},
 afterEvents:{playerBreakBlock:{subscribe(f){globalThis.__brk=f}},playerPlaceBlock:{subscribe(){}},playerDimensionChange:{subscribe(){}},playerSpawn:{subscribe(){}},itemUse:{subscribe(){}},entityDie:{subscribe(){}}}};
let handler; export const system={get currentTick(){return tick},afterEvents:{scriptEventReceive:{subscribe(f){handler=f}}},
 runTimeout:(f,t)=>{timers.push([tick+t,f]);return timers.length},clearRun:(i)=>{timers[i-1]=null},run:(f)=>f()};
export const __t={sent,players,props,advance(n){tick+=n;for(const t of timers.splice(0))if(t&&t[0]<=tick)t[1]();},fire(id,msg,src){handler({id,message:msg,sourceEntity:src})}};
