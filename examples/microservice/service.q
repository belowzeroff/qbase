// qbase example: REST microservice exposing JSON metrics over HTTP
//
// Launch with examples/microservice/run.sh, or directly:
//   QBASE_HOME=/path/to/qbase q examples/microservice/service.q -p 8080
//
// Then:  curl http://localhost:8080/metrics

// -- Bootstrap qbase --------------------------------------------------------

qbaseHome:getenv`QBASE_HOME;

if[0 = count qbaseHome;
    '"QBASE_HOME must point at the qbase repository root (see run.sh)";
 ];

system "l ",qbaseHome,"/src/require.q";
.require.init hsym `$qbaseHome;
.require.lib each `log`cargs;


// -- Application ------------------------------------------------------------

.ms.startTime:.z.p;

/  @returns (Dict) A snapshot of process metrics
.ms.metrics:{
    w:.Q.w[];
    :`service`status`uptime`kdbVersion`usedBytes`heapBytes!(
        "qbase-microservice";
        "ok";
        string .z.p - .ms.startTime;
        .z.K;
        w`used;
        w`heap);
 };

/ Builds a complete HTTP response string
.ms.i.respond:{[status; contentType; body]
    nl:"\r\n";
    :nl sv (
        "HTTP/1.1 ",status;
        "Content-Type: ",contentType;
        "Content-Length: ",string count body;
        "Connection: close";
        "";
        body);
 };


// -- HTTP GET routing (.z.ph is kdb+'s built-in HTTP GET hook) --------------

.z.ph:{[req]
    url:$[0h = type req; req 0; req];
    path:first "?" vs url;

    .log.info ("HTTP GET [ Path: {} ]"; path);

    $[path ~ "metrics";
        .ms.i.respond["200 OK"; "application/json"; .j.j .ms.metrics[]];
    (path ~ "") | path ~ "/";
        .ms.i.respond["200 OK"; "application/json"; .j.j `service`endpoints!("qbase-microservice"; enlist "/metrics")];
    / else
        .ms.i.respond["404 Not Found"; "text/plain"; "No such endpoint: ",path]
    ]
 };

.log.info ("qbase microservice ready [ Port: {} ] [ Endpoints: / /metrics ]"; system "p");
