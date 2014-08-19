q src/kdb/common/vct_proc.q -vct-load src/kdb/database/tick.q -vct-schema vct -vct-tplog $VCT_HDB </dev/null >$VCT_WKSP_LOG/tick.log 2>&1 &
q $VCT_HDB/vct -p 5012 </dev/null >$VCT_WKSP_LOG/hdb.log 2>&1 &
q src/kdb/common/vct_proc.q -vct-load src/kdb/database/r.q  -vct-tick :5010 -vct-hdb :5012 -p 5011 </dev/null >$VCT_WKSP_LOG/rtd.log 2>&1 &
q src/kdb/common/vct_proc.q -vct-load src/kdb/exch/curlrest/curlexch.q -vct-tick :5010 </dev/null >$VCT_WKSP_LOG/exchcurl.log 2>&1 &
