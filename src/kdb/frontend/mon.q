\c 30 120
\d .schema
.vct.load "/src/kdb/common/vct_schema.q"
\d .
.vct.load "/src/kdb/util/json.k"
.vct.load "/src/kdb/html.q"
.vct.load "/src/kdb/monitor.q"
heartbeat:([]time:`timestamp$(); sym:`symbol$(); procname:`symbol$(); counter:`long$())
.hb.hb:update warning:0b, error:0b from `sym`procname xkey heartbeat
logmsg:([]time:`timestamp$(); sym:`symbol$(); host:`symbol$(); loglevel:`symbol$(); id:`symbol$(); message:())
