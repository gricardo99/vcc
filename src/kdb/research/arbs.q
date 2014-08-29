getmktandarbs:{[]getmktdata[]; getarbs[1000f;tm:last exec timestamp from quote];}
getmktdata:{[] getexchdata each key exchurl;}
getexchdata:{[exch] res:@[curlexch;exchurl[exch];{[x;e] -2"Failed to get exch",string[x];}[exch]]; if[1<count res;(value exch) .j.k res];}

.ccy.fiat:`USD`EUR;
.ccy.cryp:`BTC`LTE`XRP;

.fees.trade:{[ex;bs;amt] k:(ex;bs);fees[k;`tradev]*amt}
.fees.draw:{[ex;bs;amt] k:(ex;bs);fees[k;`drawmin]|fees[k;`drawf]+fees[k;`drawv]*amt}
.fees.dep:{[ex;bs;amt] k:(ex;bs);fees[k;`depmin]|fees[k;`depf]+fees[k;`depv]*amt}
.fees.arb:{[endf;bank;ex1;ex2;amt1;amt2;btcpx] ((amt1%valatrisk)*.fees.draw[bank;`USD;amt1]) + .fees.dep[ex1;`USD;amt1] + .fees.trade[ex1;`USD;amt1] + (btcpx*(.fees.draw[ex1;`BTC;amt1%btcpx] + .fees.dep[ex2;`BTC;amt1%btcpx])) + .fees.trade[ex2;`USD;amt2] + endf*(.fees.draw[ex2;`USD;amt2] + .fees.dep[bank;`USD;amt2])}
fees:`exch`baseccy xkey .schema.fees;
loadfees:{[fnm]
	tmp: ("SSFFFFFFF";enlist csv) 0: read0 hsym `$fnm;
	`fees upsert `timestamp xcols update time:.z.N,timestamp:.z.P from tmp;
	}
loadfees[.vct.home,"/config/fees.csv"];
arbopts:.schema.arbopts;
getarbstm:{[d;tm;val;exch1;exch2]
	exch1q:(curqt:select from quote where timestamp>(`timestamp$d)) asof `exch`timestamp!(exch1;tm);
	exch2q:curqt asof `exch`timestamp!(exch2;tm);
	if[exch1q[`apx]<exch2q[`bpx];
		getarbqt[val;exch1;exch2;exch1q;exch2q;tm];
	];
	}
amtval:{[prcs;szs;amount] vall:szs*prcs; cnt:0|(count vall) - count (sval) where (sval:sums vall)>amount; $[cnt<2;first prcs;(((cnt-1)#szs),((amount-sval[cnt-1])%prcs[cnt-1])) wavg (((cnt-1)#prcs),(prcs[cnt-1]))]}
getarbqt:{[val;exch1;exch2;exch1q;exch2q;tm]
	buypxl:exch1q[`aprcs] where exch1q[`aprcs]<exch2q[`bpx];
	if[count buypxl;
		buyamtl:(count buypxl)#exch1q[`aszs];
		vall:(+) scan buypxl * buyamtl;
		buycnt:count buys:buypxl where (vall<val);
		lastbuy:buypxl buycnt;
		lastsz:($[(vd:val-vall[(buycnt-1)|0])>0;vd;val])%lastbuy;
		valb:sum (buypxl:buys,lastbuy)*buysl:(buyamtl where (vall<val)),lastsz;
		bwpx:buysl wavg buypxl;
		sellcnt:count sellszl:exch2q[`bszs] where not (sells:(+) scan exch2q[`bszs])>sum buysl;
		lastsellsz:(sum buysl)-sum sellszl;
		sellval:sum (sellszl:sellszl,lastsellsz) * (sellpxl:(sellcnt+1)#exch2q[`bprcs]);
		gpnl:(sellval-valb);
	    if[gpnl<=0;:()];
		nroi:100*(gpnl-fees:.fees.arb[0b;`citigold;exch1;exch2;valb;sellval;bwpx])%valb;
		`arbopts upsert narb:(tm;`BTCUSD;exch1;exch2;sum buysl;bwpx;sellszl wavg sellpxl;valb;gpnl;fees;nroi);
	];
	}
getarbsexch:{[val;tml;exch1;exch2] raze getarbstm[;val;exch1;exch2] each tml}
getallarbs:{[val]
	exchtm:first exec exch from `x xdesc select count i by exch from quote;
	tml:exec distinct timestamp from quote where exch=exchtm;
	getarbsexch[val;tml] .' arbexchl::(exchcombo) where (not (=) .' exchcombo:(key exchurl) cross (key exchurl));
	}
getarbs:{[val;d;tm] getarbstm[d;tm;val] .' arbexchl::(exchcombo) where (not (=) .' exchcombo:(key exchurl) cross (key exchurl)); }
