if[not count .vct.home:getenv(`VCT_HOME);-2 string[.z.Z],": Error:  Must have shell var VCT_HOME set to top of git vcc.";exit 1];
.vct.load:{[x] system"l ",.vct.home,x};
