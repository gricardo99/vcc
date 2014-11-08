\c 30 120
.vct.load "src/kdb/common/vct_ps.q"
.vct.load "src/kdb/util/json.k"
.vct.load "src/kdb/frontend/html.q"
.vct.load "src/kdb/frontend/monitor.q"
logmsg:([]time:`timestamp$(); sym:`symbol$(); host:`symbol$(); loglevel:`symbol$(); id:`symbol$(); message:())
