exchstats:{[e;sm;x] `curltottime upsert st:(.z.N;sm;e;x;.z.P);
	.vct.publish[`curltottime;st];
	};
maxamt:100000;
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
	bprcs:"F"$string key ((d`data)`buy);
	bszs:"F"$string value ((d`data)`buy);
	aprcs:"F"$string key ((d`data)`sell);
	aszs:"F"$string value ((d`data)`sell);
	quoteupsrt[exch;sm;bprcs;bszs;aprcs;aszs;.z.P];
	}
bxinth:parseq1;
bter:parseq2;
