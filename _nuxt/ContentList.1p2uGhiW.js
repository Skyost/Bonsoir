import n from"./ContentQuery.UE16qZVB.js";import{d as c,E as l,G as f}from"./entry.Dsx7KDQe.js";import"./query.779u5JT1.js";import"./preview.XpYOfn7-.js";const u=(r,t)=>f("pre",null,JSON.stringify({message:"You should use slots with <ContentList>",slot:r,data:t},null,2)),h=c({name:"ContentList",props:{path:{type:String,required:!1,default:void 0},query:{type:Object,required:!1,default:void 0}},render(r){const t=l(),{path:p,query:a}=r,m={...a||{},path:p||(a==null?void 0:a.path)||"/"};return f(n,m,{default:t!=null&&t.default?({data:e,refresh:o,isPartial:d})=>t.default({list:e,refresh:o,isPartial:d,...this.$attrs}):e=>u("default",e.data),empty:e=>t!=null&&t.empty?t.empty(e):u("default",e==null?void 0:e.data),"not-found":e=>{var o;return t!=null&&t["not-found"]?(o=t==null?void 0:t["not-found"])==null?void 0:o.call(t,e):u("not-found",e==null?void 0:e.data)}})}}),L=h;export{L as default};
