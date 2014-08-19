if[not count .vct.home:getenv(`VCT_WKSP_HOME);-2 string[.z.Z],": Error:  Must have shell var VCT_WKSP_HOME set to top of git vcc.";exit 1];
.vct.larg:`$"vct-load";
.vct.load:{[x] system"l ",.vct.home,"/",x};
if[.vct.larg in key .vct.opts:.Q.opt .z.x;.vct.load raze .vct.opts[.vct.larg]];
