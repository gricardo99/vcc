
.vct.load "/src/kdb/common/vct_ps.q"
quote:`exch`sym xkey .schema.quote
.tide.exchl:`btce`bitfinex;
.tide.syml:`BTC;
.sub.slist:`curlexch;

.btce.tradefee:0.2 /percent
.btce.wfee:0.001 /BTC
.bitfinex.tradefee:0.2 /percent
outfee:.btce.tradefee+(2*.bitfinex.tradefee)+0.1
infee:.btce.tradefee+(2*.bitfinex.tradefee);

.tide.quote:{[x]
	if[x[`exch] in .tide.exchl;
		if[x[`sym] in .tide.syml;
			`quote upsert x;
			buypct:(100*(quote[(`bitfinex;`BTC);`bpx] - quote[(`btce;`BTC);`apx])% quote[(`btce;`BTC);`apx]) - outfee;
			buysz:min quote[(`bitfinex;`BTC);`bsz] quote[(`btce;`BTC);`asz];
			sellpct:(100*(quote[(`btce;`BTC);`bpx] - quote[(`bitfinex;`BTC);`apx])%quote[(`bitfinex;`BTC);`apx]) - infee;
			sellsz:min quote[(`bitfinex;`BTC);`asz] quote[(`btce;`BTC);`bsz];
			qt:(.z.N;`BTC;exchp:`$"btce-bitfinex";buypct;buysz;sellpct;sellsz;.z.P);
			.vct.publish[`tidecalc;qt];
			.vct.publish[`heartbeat;(.z.N;`BTC;`;`;.vct.host;.vct.proc.z.P)];
		];
	];
	}
upd:{[t;x] if[t=`quote; .tide.quote[x] ]; }

.sub.conn[];
