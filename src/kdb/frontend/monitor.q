// set up the upd function to handle heartbeats
upd:{[t;x]
 $[t=`heartbeat;
 	[.hb.storeheartbeat[x]; 
	 // publish to web pages 
 	 .html.pub[`heartbeat;hbdata[]]];
  t=`logmsg;
	[insert[`logmsg;x]; 
	 // publish to web pages
 	 .html.pub[`logmsg;lmdata[]]];
  t=`quote;
	//[insert[`quote;x]; 
	 // publish to web pages
 	 .html.pub[`mychart;x]];
  ()]}


// subscribe to heartbeats and log messages on a handle
/subscribe:{[handle]
/ subscribedhandles,::handle;
/ @[handle;(`.ps.subscribe;`heartbeat;`);{.lg.e[`monitor;"failed to subscribe to logmsg on handle ",(string x),": ",y]}[handle]];
/ @[handle;(`.ps.subscribe;`logmsg;`);{.lg.e[`monitor;"failed to subscribe to logmsg on handle ",(string x),": ",y]}[handle]];
/ }
 
// if a handle is closed, remove it from the list
.z.pc:{if[y;subscribedhandles::subscribedhandles except y]; x@y}@[value;`.z.pc;{{[x]}}]

// Make the connections and subscribe
/.servers.startup[]
/subscribe each (exec w from .servers.SERVERS) except subscribedhandles;

// As new processes become available, try to connect 
/.servers.addprocscustom:{[connectiontab;procs]
/ .lg.o[`monitor;"received process update from discovery service for process of type "," " sv string procs,:()];
/ .servers.retry[];
/ subscribe each (exec w from .servers.SERVERS) except subscribedhandles;
/ }


// GUI

// initialise pubsub
.html.init`heartbeat`logmsg`lmchart
cvrt2unixtm:{[x] `int$((`long$x)%1000000000)+946684800}

mychart:asc ([] mytime:cvrt2unixtm each 2014.11.02D00:00:00.0 + 1000?80000000000000; myval:1000?10i);
/- Table data functions - Return unkeyed sorted tables
hbdata:{0! delete time from .hb.hb}
chartdata:{ 0!`mytime xasc mychart}
lmdata:{0!`time xdesc -20 sublist logmsg}

/- Chart data functions - Return unkeyed chart data
lmchart:{0!select errcount:count i by 0D00:05 xbar time from logmsg where loglevel=`ERR}
bucketlmchartdata:{[x] x:`minute$$[x=0;1;x];0!select errcount:count i by (0D00:00+x) xbar time from logmsg where loglevel=`ERR}

/- Data functions - These are functions that are requested by the front end
/- start is sent on each connection and refresh. Where there are more than one table it is wise to identify each one using a dictionary as shown
start:{.html.wssub each `heartbeat`logmsg`lmchart; -2"got start";
        htmldata:.html.dataformat["start";(`charttable`lmtable`lmchart)!(chartdata[];lmdata[];lmchart[])]; 0N!htmldata;:htmldata}
bucketlmchart:{.html.dataformat["bucketlmchart";enlist bucketlmchartdata[x]]}

/monitorui:.html.readpagereplaceHP["index.html"]
.sub.slist:`curlexch`bitstamp`okcoin`tidecalc;
monlist:`tick`rtd`hdb
.hb.hb:`proc`name`sym xkey .schema.heartbeat;
.hb.storeheartbeat:{[x] `.hb.hb upsert x }
.hb.ping:{[x] neg[.z.w](`.hb.resp;`;.vct.host;.vct.proc;x)}
.hb.resp:{[n;h;p;x] `.hb.hb upsert (p;n;.z.N;`;h;`pong;x) }
.hb.monh:0#0i;
.hb.conn:{[] .hb.monh,:(exec {[pr;h;p] @[hopen;hsym `$string[h],":",string[p];{[pr;e] -2"Failed to connect to proc:",string[pr];:0N}[pr]]}'[proc;host;port] from proclist where proc in monlist) except 0N; `.hb.hb upsert select proc,name:`,host,status:`init from proclist where proc in monlist};
.hb.pingall:{[] neg[.hb.monh]@\:(.hb.ping;.z.P); }
.hb.check:{[] update status:`timeout from `.hb.hb where (.z.P-timestamp)>0D00:00:30.0;}
.z.pc:{if[y;.hb.monh:.hb.monh except y]; x@y}@[value;`.z.pc;{{[x]}}]
.z.ts:{[x] .hb.pingall[];.hb.check[]; }@[value;`.z.pc;{{[x]}}]
\t 2000
.hb.conn[];
.sub.conn[];

