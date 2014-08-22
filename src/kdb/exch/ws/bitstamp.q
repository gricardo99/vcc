/r:(`$":ws://host:port")""GET /path HTTP/1.1\r\nHost: host:port\r\n\r\n"
.vct.load "/src/kdb/util/json.k"
.vct.load "/src/kdb/common/vct_ps.q"
\c 30 120
\d .schema
.vct.load "/src/kdb/common/vct_schema.q"
\d .
quote:`sym`exch xkey .schema.quote;
curltottime:.schema.curltottime;
.vct.load "/src/kdb/exch/parse_ob.q"
bitstamp_sub_msg:"{\"event\":\"pusher:subscribe\",\"data\": {\"channel\": \"order_book\"}}";
bitstamp_sub_done:0b;
.z.ws:{ 	if[10h=type x;
			d:.j.k x;
			if[`event in key d;
				if[(`$d[`event])=`$"pusher:connection_established";
					neg[bitstamph] bitstamp_sub_msg;
				];
				if[(`$d[`event])=`$"pusher_internal:subscription_succeeded";
					bitstamp_sub_done::1b;
				];
				if[(`$d[`event])=`$"data";
					if[bitstamp_sub_done; bitstamp[d`data]; ];
				];
			];
		];
	} 
bitstamph:first (`$":ws://ws.pusherapp.com") "GET  /app/de504dc5763aeef9ff52?client=js&version=3.0&protocol=6 HTTP/1.1\r\nHost: ws.pusherapp.com\r\n\r\n"
bitstamp:{[x] parseq1[`bitstamp;`BTCUSD;x;-9999f]; }

