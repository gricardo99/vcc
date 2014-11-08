if[not count .vct.home:getenv(`VCT_WKSP_HOME);-2 string[.z.Z],": Error:  Must have shell var VCT_WKSP_HOME set to top of git vcc.";exit 1];
.vct.larg:`$"vct-load";
.vct.load:{[x] system"l ",.vct.home,"/",x};
\d .schema
.vct.load "src/kdb/common/vct_schema.q"
\d .
.vct.setcols:{[t] (`$".schema.cols.",string[t]) set cols .schema[t]; }
.vct.setcols each tables[`.schema];
if[.vct.larg in key .vct.opts:.Q.opt .z.x;.vct.load raze .vct.opts[.vct.larg]];
.vct.proc:$[`NAME in key .vct.opts;first `$.vct.opts`NAME;not null fnm:`$(last "/" vs raze .vct.opts .vct.larg) except ".q";.vct.proc:fnm;`$"unknown-",string[.z.i]];
.vct.host:first `$system"hostname -f";
