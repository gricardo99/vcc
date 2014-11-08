/dead simple to start, requires tp host/port, opens handle and .vct.snd only sends to tp
if[not (.vct.tick:`$"vct-tick") in key .vct.opts; -2 string[.z.Z],": ERROR! must specify tickerplant connection with -vct-tick <HOST:PORT> arg."; exit 1];
.vct.tickconn:raze .vct.opts .vct.tick;
.vct.tickh:hopen `$":",.vct.tickconn;
.vct.publish:{[t;x] if[not null .vct.tickh;neg[.vct.tickh](`.u.upd;t;x)]; .vct.conn@\:(`upd;t;.schema.cols[t]!x)}
.vct.conn:0#0i
.z.pc:{if[y;.vct.conn:.vct.conn except y]; x@y}@[value;`.z.pc;{{[x]}}]
.vct.sub:{[] .vct.conn:distinct neg (.vct.conn,.z.w) except .vct.tickh;}
proclist:("SSI";enlist csv)0: read0 hsym `$.vct.home,"/config/proclist.csv";
.sub.hl:0#0i
.sub.conn:{[] .sub.hl,:(exec {[pr;h;p] @[hopen;hsym `$string[h],":",string[p];{[pr;e] -2"Failed to connect to proc:",string[pr];:0N}[pr]]}'[proc;host;port] from proclist where proc in .sub.slist) except 0N;  neg[.sub.hl]@\:".vct.sub[]";}
