.vct.load "/src/kdb/util/json.k"
.vct.load "/src/kdb/common/vct_ps.q"
\c 30 120
\d .schema
.vct.load "/src/kdb/common/vct_schema.q"
\d .
quote:.schema.quote;
curltottime:.schema.curltottime;
exchstats:{[e;sm;x] `curltottime upsert st:(.z.N;sm;e;x;.z.P);
	.vct.publish[`curltottime;st];
	};
maxamt:100000;
valatrisk:10000;
newexchl:enlist `coinsetter;
newexchurl:newexchl!(`$"https://api.coinsetter.com/v1/marketdata/depth?depth=MAX&format=LIST&exchange=COINSETTER");
quoteupsrt:{[exch;sm;bprcs;bszs;aprcs;aszs;exchtm]
	blmt:((count accumval)-(count accumval where (accumval:(+) scan (*) .' (bprcs ,' bszs))>maxamt));
	bpx:first bprcs;bsz:first bszs;
	almt:((count accumval)-(count accumval where (accumval:(+) scan (*) .' (aprcs ,' aszs))>maxamt));
	apx:first aprcs;asz:first aszs;
	`quote upsert qt:(.z.N;sm;exch;bpx;apx;bsz;asz;blmt#bprcs;almt#aprcs;blmt#bszs;almt#aszs;`int$();`int$();exchtm;.z.P);
	.vct.publish[`quote;qt];
	}
parseq1:{[exch;sm;x;s] d:.j.k x;
	exchstats[exch;sm;s];
	bidl:flip "F"$d`bids;
	bprcs:bidl 0; bszs:bidl 1;
	offerl:flip "F"$d`asks;
	aprcs:offerl 0; aszs:offerl 1;
	quoteupsrt[exch;sm;bprcs;bszs;aprcs;aszs;.z.P];
	}
bitstamp:parseq1;
hitbtc:parseq1;
itbit:parseq1;
bitfinex:{[exch;sm;d;s] d:.j.k d;
	exchstats[exch;sm;s];
	bprcs:"F"$(d`bids)`price;
	bszs:"F"$(d`bids)`amount;
	aprcs:"F"$(d`asks)`price;
	aszs:"F"$(d`asks)`amount;
	quoteupsrt[`bitfinex;sm;bprcs;bszs;aprcs;aszs;.z.P];
	}
parseq2:{[exch;sm;d;s] d:.j.k d;
	exchstats[exch;sm;s];
	bidl:flip d`bids;
	bprcs:bidl 0; bszs:bidl 1;
	offerl:flip d`asks;
	aprcs:offerl 0; aszs:offerl 1;
	quoteupsrt[exch;sm;bprcs;bszs;aprcs;aszs;.z.P];
	}
btce:parseq2;
lakebtc:parseq2;
kraken:{[exch;sm;d;s] d:.j.k d;
	exchstats[exch;sm;s];
	bprcs:bszs:aprcs:aszs:enlist 0n;
	if[count d;
	   bprcs:"F"$(bl:flip raze (value (d`result))`bids) 0;
	   bszs:"F"$bl 1;
	   aprcs:"F"$(al:flip raze (value (d`result))`asks) 0;
	   aszs:"F"$al 1;
	];
   quoteupsrt[`kraken;sm;bprcs;bszs;aprcs;aszs;.z.P];
	}
okcoin:parseq2;
cryptsy:{[exch;sm;d;s] d:.j.k ssr[d;"\\";""];
	exchstats[exch;sm;s];
	mkt:`$3#string sm;
    st:select from (update sumval:sums usdval from select apx:"F"$price,asz:"F"$quantity,usdval:"F"$total from selltab:(((d`return)`markets) mkt)`sellorders) where sumval<maxamt;
    bt:select from (update sumval:sums usdval from select bpx:"F"$price,bsz:"F"$quantity,usdval:"F"$total from buytab:(((d`return)`markets) mkt)`buyorders) where sumval<maxamt;
    trades:(((d`return)`markets) mkt)`recenttrades;
    quoteupsrt[`cryptsy;sm;exec bpx from bt;exec bsz from bt;exec apx from st;exec asz from st;.z.P];
    };
bittrex:{[exch;sm;d;s] d:.j.k d; 
	exchstats[exch;sm;s];
	bprcs:((d`result)`buy)`Rate;
	bszs:((d`result)`buy)`Quantity;
	aprcs:((d`result)`sell)`Rate;
	aszs:((d`result)`sell)`Quantity;
	quoteupsrt[exch;sm;bprcs;bszs;aprcs;aszs;.z.P];
	};
anxpro:{[exch;sm;d;s] d:.j.k d; 
	exchstats[exch;sm;s];
	bprcs:"F"$((d`data)`bids)`price;
	bszs:"F"$((d`data)`bids)`amount;
	aprcs:"F"$((d`data)`asks)`price;
	aszs:"F"$((d`data)`asks)`amount;
	quoteupsrt[exch;sm;bprcs;bszs;aprcs;aszs;.z.P];
	}
allcoin:{[exch;sm;d;s] d:.j.k d; 
	exchstats[exch;sm;s];
	bprcs:key ((d`data)`buy);
	bszs:value ((d`data)`buy);
	aprcs:key ((d`data)`sell);
	aszs:value ((d`data)`sell);
	quoteupsrt[exch;sm;bprcs;bszs;aprcs;aszs;.z.P];
	}
bxinth:parseq1;
bter:parseq2;


loadoburls:{[fnm] .exch.oburl:1!("SS";enlist csv) 0: read0 hsym `$fnm; }
loadoburls[.vct.home,"/config/oburl.csv"];
exchl:exec distinct exch from .exch.oburl;
loadexchsyml:{[exch] fnm:.vct.home,"/config/",string[exch],"-sym.csv"; if[count key fh:hsym `$fnm;(`$".exchsyms.",string[exch])set 1!("SS";enlist csv) 0: read0 fh;]; }
loadexchsyml each exchl;
cvrturl:{[x;s] `$ssr[string x;"<SYM>";string s]}
getoburl:{[exch;s] cvrturl[.exch.oburl[exch]`oburl;(.exchsyms[exch])[s]`exchsym]}

curlib:`$.vct.home,"/src/c/exch/curlrest/libcurlkdb";
curlexchinit:(curlib)2:(`kx_exch_init;6) /exch,sym,proxyl,cb,url,pollf
{[exch] {[exch;s] curlexchinit[exch;s;`;exch;getoburl[exch;s];60] }[exch] each exec sym from .exchsyms[exch] } each exchl
