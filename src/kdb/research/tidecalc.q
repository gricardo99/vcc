
.vct.load "/src/kdb/common/vct_ps.q"
quote:`exch`sym xkey .schema.quote
.tide.exchl:`btce`bitfinex;
.tide.syml:`BTCUSD;
.sub.slist:`curlexch;

.btce.tradefee:0.2 /percent
.btce.wfee:0.001 /BTCUSD
.bitfinex.tradefee:0.2 /percent
outfee:.btce.tradefee+(2*.bitfinex.tradefee)+0.1
infee:.btce.tradefee+(2*.bitfinex.tradefee);

.tide.quote:{[x]
	if[x[`exch] in .tide.exchl;
		if[x[`sym] in .tide.syml;
			`quote upsert x;
			buypct:(100*(quote[(`bitfinex;`BTCUSD);`bpx] - quote[(`btce;`BTCUSD);`apx])% quote[(`btce;`BTCUSD);`apx]) - outfee;
			if[null buypct; :()];
			buysz:min (quote[(`bitfinex;`BTCUSD);`bsz];quote[(`btce;`BTCUSD);`asz]);
			sellpct:(100*(quote[(`btce;`BTCUSD);`bpx] - quote[(`bitfinex;`BTCUSD);`apx])%quote[(`bitfinex;`BTCUSD);`apx]) - infee;
			if[null sellpct; :()];
			sellsz:min (quote[(`bitfinex;`BTCUSD);`asz]; quote[(`btce;`BTCUSD);`bsz]);
			qt:(.z.N;`BTCUSD;exchp:`$"btce-bitfinex";buypct;buysz;sellpct;sellsz;.z.P);
			.vct.publish[`tidecalc;qt];
			.vct.publish[`heartbeat;(.z.N;`BTCUSD;`;`;.vct.host;.vct.proc;.z.P)];
		];
	];
	}
upd:{[t;x] if[t=`quote; .tide.quote[x]];}

.sub.conn[];
