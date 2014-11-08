q $VCT_WKSP_HOME/src/kdb/common/vct_proc.q -vct-load src/kdb/database/tick.q -vct-schema vct -vct-tplog $VCT_HDB </dev/null >$VCT_WKSP_LOGS/tick.log 2>&1 &
sleep 1
q $VCT_HDB/vct -p 5012 </dev/null >$VCT_WKSP_LOGS/hdb.log 2>&1 &
q $VCT_WKSP_HOME/src/kdb/common/vct_proc.q -vct-load src/kdb/database/r.q  -vct-tick :5010 -vct-hdb :5012 -p 5011 </dev/null >$VCT_WKSP_LOGS/rtd.log 2>&1 &
sleep 1
q $VCT_WKSP_HOME/src/kdb/common/vct_proc.q -vct-load src/kdb/exch/curlrest/curlexch.q -vct-tick :5010 -p 5013 </dev/null >$VCT_WKSP_LOGS/curlexch.log 2>&1 &
q $VCT_WKSP_HOME/src/kdb/common/vct_proc.q -vct-load src/kdb/exch/ws/bitstamp.q  -vct-tick :5010 -p 5014  </dev/null >$VCT_WKSP_LOGS/bitstamp.log 2>&1 &
q $VCT_WKSP_HOME/src/kdb/common/vct_proc.q -vct-load src/kdb/exch/ws/okcoin.q  -vct-tick :5010 -p 5015 </dev/null >$VCT_WKSP_LOGS/okcoin.log 2>&1 &
