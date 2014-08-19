/ q tick.q sym . -p 5001 </dev/null >foo 2>&1 &

/q tick.q SRC [DST] [-p 5010] [-o h]
/system"l tick/",(src:first .z.x,enlist"sym"),".q"
if[not (.vct.sarg:`$"vct-schema") in key .vct.opts; -2 string[.z.Z],": ERROR! vct tickerplant must have -vct-schema <SCHEMA NAME> arg."; exit 1];
if[not (.vct.tparg:`$"vct-tplog") in key .vct.opts; -2 string[.z.Z],": ERROR! vct tickerplant must have -vct-tplog <TICKERPLANT LOG DIR> arg."; exit 1];
src:raze .vct.opts .vct.sarg;
tpdir:raze .vct.opts .vct.tparg;
.vct.load "src/kdb/common/",src,"_schema.q"

if[not system"p";system"p 5010"]

.vct.load "src/kdb/database/u.q"
\d .u
ld:{if[not type key L::`$(-10_string L),string x;.[L;();:;()]];i::j::-11!(-2;L);if[0<=type i;-2 (string L)," is a corrupt log. Truncate to length ",(string last i)," and restart";exit 1];hopen L};
tick:{init[];if[not min(`time`sym~2#key flip value@)each t;'`timesym];@[;`sym;`g#]each t;d::.z.D;if[l::count y;L::`$":",y,"/",x,10#".";l::ld d]};

endofday:{end d;d+:1;if[l;hclose l;l::0(`.u.ld;d)]};
ts:{if[d<x;if[d<x-1;system"t 0";'"more than one day?"];endofday[]]};

if[system"t";
 .z.ts:{pub'[t;value each t];@[`.;t;@[;`sym;`g#]0#];i::j;ts .z.D};
 upd:{[t;x]
 if[not -16=type first first x;if[d<"d"$a:.z.P;.z.ts[]];a:"n"$a;x:$[0>type first x;a,x;(enlist(count first x)#a),x]];
 t insert x;if[l;l enlist (`upd;t;x);j+:1];}];

if[not system"t";system"t 1000";
 .z.ts:{ts .z.D};
 upd:{[t;x]ts"d"$a:.z.P;
 if[not -16=type first first x;a:"n"$a;x:$[0>type first x;a,x;(enlist(count first x)#a),x]];
 f:key flip value t;pub[t;$[0>type first x;enlist f!x;flip f!x]];if[l;l enlist (`upd;t;x);i+:1];}];

\d .
.u.tick[src;tpdir];

\
 globals used
 .u.w - dictionary of tables->(handle;syms)
 .u.i - msg count in log file
 .u.j - total msg count (log file plus those held in buffer)
 .u.t - table names
 .u.L - tp log filename, e.g. `:./sym2008.09.11
 .u.l - handle to tp log file
 .u.d - date

/test
>q tick.q
>q tick/ssl.q

/run
>q tick.q sym  .  -p 5010   /tick
>q tick/r.q :5010 -p 5011   /rdb
>q sym            -p 5012   /hdb
>q tick/ssl.q sym :5010     /feed
