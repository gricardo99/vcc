.vct.load "/src/kdb/util/json.k"
.vct.load "/src/kdb/common/vct_ps.q"
\c 30 120
\d .schema
.vct.load "/src/kdb/common/vct_schema.q"
\d .
.vct.load "/src/kdb/exch/parse_ob.q"
quote:`sym`exch xkey .schema.quote;
curltottime:.schema.curltottime;

loadoburls:{[fnm] .exch.oburl:1!("SS";enlist csv) 0: read0 hsym `$fnm; }
loadoburls[.vct.home,"/config/oburl.csv"];
exchl:exec distinct exch from .exch.oburl;
loadexchsyml:{[exch] fnm:.vct.home,"/config/",string[exch],"-sym.csv"; if[count key fh:hsym `$fnm;(`$".exchsyms.",string[exch])set 1!("SS";enlist csv) 0: read0 fh;]; }
loadexchsyml each exchl;
cvrturl:{[x;s] `$ssr[string x;"<SYM>";string s]}
getoburl:{[exch;s] cvrturl[.exch.oburl[exch]`oburl;(.exchsyms[exch])[s]`exchsym]}

curlib:`$.vct.home,"/src/c/exch/curlrest/libcurlkdb";
curlexchinit:(curlib)2:(`kx_exch_init;6) /exch,sym,proxyl,cb,url,pollf
{[exch] {[exch;s] curlexchinit[exch;s;`;exch;getoburl[exch;s];$[exch in `btce`bitfinex;2;30]] }[exch] each exec sym from .exchsyms[exch] } each exchl
