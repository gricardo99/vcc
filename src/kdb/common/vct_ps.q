/dead simple to start, requires tp host/port, opens handle and .vct.snd only sends to tp
if[not (.vct.tick:`$"vct-tick") in key .vct.opts; -2 string[.z.Z],": ERROR! must specify tickerplant connection with -vct-tick <HOST:PORT> arg."; exit 1];
.vct.tickconn:raze .vct.opts .vct.tick;
.vct.tickh:hopen `$":",.vct.tickconn;
.vct.setcols:{[t] (`$".schema.cols.",string[t]) set cols .schema[t]; }
.vct.setcols each tables[`.schema];
.vct.publish:{[t;x] if[not null .vct.tickh;neg[.vct.tickh](`.u.upd;t;x)]; .vct.conn@\:(`upd;t;.schema.cols[t]!x)}
.vct.conn:0#0i
.vct.sub:{[] .vct.conn,:neg .z.w }
