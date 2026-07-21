// qbase example: hybrid q + Python (PyKX) data pipeline
//
// Requires PyKX (pip install pykx) with its q interface (pykx.q) loaded.
//   ./run.sh

// -- Bootstrap qbase --------------------------------------------------------

qbaseHome:getenv`QBASE_HOME;
if[0 = count qbaseHome; '"QBASE_HOME must point at the qbase repository root"];

system "l ",qbaseHome,"/src/require.q";
.require.init hsym `$qbaseHome;
.require.lib each `log`py;


// -- Guard: PyKX must be available ------------------------------------------

if[not .py.cfg.enabled;
    .log.warn "PyKX is not available in this process.";
    .log.warn "Install it (pip install pykx) and load 'pykx.q', then re-run this example.";
    exit 0;
 ];


// -- Pipeline: q -> Pandas -> (transform in Python) -> q --------------------

trades:([] sym:`AAPL`MSFT`AAPL`GOOG; price:100 200 101 300f; size:10 5 7 3);
.log.info ("Built sample table [ Rows: {} ]"; count trades);

df:.py.toPandas trades;
.log.info "Converted q table -> Pandas DataFrame";

/ Example Python-side transformation (grouped mean price) via PyKX:
/   pandas is available to the PyKX interpreter as 'pd'
grouped:.py.toq .py.eval["lambda t: t.groupby('sym').price.mean().reset_index()"] df;
.log.info ("Pipeline complete [ Groups: {} ]"; count grouped);

show grouped;

exit 0;
