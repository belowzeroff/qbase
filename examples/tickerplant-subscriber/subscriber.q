// qbase example: tickerplant subscriber
//
// Connects to a kdb+ tickerplant, subscribes to its tables and processes updates.
// Requires a running tickerplant (e.g. KxSystems/kdb-tick).
//
//   TP_HOST=localhost TP_PORT=5010 ./run.sh

// -- Bootstrap qbase --------------------------------------------------------

qbaseHome:getenv`QBASE_HOME;
if[0 = count qbaseHome; '"QBASE_HOME must point at the qbase repository root"];

system "l ",qbaseHome,"/src/require.q";
.require.init hsym `$qbaseHome;
.require.lib each `log`cargs`ipc;


// -- Subscription config ----------------------------------------------------

.sub.cfg.tables:`;   // ` = all tables
.sub.cfg.syms:`;     // ` = all symbols

/ Running per-table row counts
.sub.stats:([] table:`symbol$(); rows:`long$());


// -- Tickerplant update handler (called asynchronously by the TP) -----------

.u.upd:{[t; data]
    n:count first data;
    .sub.stats:.sub.stats upsert (t; n);
    .log.info ("Update [ Table: {} ] [ Rows: {} ] [ Cumulative: {} ]"; t; n; exec sum rows from .sub.stats where table = t);
 };


// -- Connect & subscribe ----------------------------------------------------

.sub.connect:{[host; port]
    hp:`$":",host,":",string port;
    .log.info ("Connecting to tickerplant [ Target: {} ]"; hp);

    h:@[hopen; hp; {[e] .log.error ("Failed to connect to tickerplant [ Error: {} ]"; e); exit 1}];

    .log.info "Connected; subscribing";
    h (`.u.sub; .sub.cfg.tables; .sub.cfg.syms);

    .log.info "Subscribed; waiting for updates";
    :h;
 };

.sub.host:$["" ~ h:getenv`TP_HOST; "localhost"; h];
.sub.port:"J"$$["" ~ p:getenv`TP_PORT; "5010"; p];

.sub.h:.sub.connect[.sub.host; .sub.port];
