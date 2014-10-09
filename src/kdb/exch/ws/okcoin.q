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
okcoin_sd:(`$"ok_btcusd_depth60";`$"ok_ltcusd_depth")!`BTCUSD`LTCUSD;
okcoin_sub_msg:"[{\"event\":\"addChannel\",\"channel\":\"ok_btcusd_depth60\"},{\"event\":\"addChannel\",\"channel\":\"ok_ltcusd_depth\"}]";
okcoin_sub_done:0b;
.z.ws:{ if[10h=type x; okcoinws[okcoin_sd;x]]} 
/okcoinh:first (`$":wss://real.okcoin.com") "GET  /websocket/okcoinapi HTTP/1.1\r\nHost: real.okcoin.com\r\n\r\n"
okcoinh:first (`$":ws://localhost:5020") "GET  /websocket/okcoinapi HTTP/1.1\r\nHost: real.okcoin.com:10440\r\n\r\n"
\sleep 5;
if[not null okcoinh;
	neg[okcoinh] okcoin_sub_msg;
	];
