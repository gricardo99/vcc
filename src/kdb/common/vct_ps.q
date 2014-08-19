/dead simple to start, requires tp host/port, opens handle and .vct.snd only sends to tp
if[not (.vct.tick:`$"vct-tick") in key .vct.opts; -2 string[.z.Z],": ERROR! must specify tickerplant connection with -vct-tick <HOST:PORT> arg."; exit 1];
.vct.tickconn:raze .vct.opts .vct.tick;
.vct.tickh:hopen `$":",.vct.tickconn;
.vct.publish:{[t;x] if[not null .vct.tickh;neg[.vct.tickh](`.u.upd;t;x)];}
