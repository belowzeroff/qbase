// qbase Tests - http (auth header helpers)
// Copyright (c) 2026 Evgen Bielozorov
// Licensed under the Apache License, Version 2.0

.require.lib`http;


.t.http_bearerHeader:{[]
    .test.assert.equals["Bearer tok123"; .http.auth.bearer "tok123"];
 };

.t.http_bearerAcceptsSymbol:{[]
    .test.assert.equals["Bearer abc"; .http.auth.bearer `abc];
 };

.t.http_basicHeader:{[]
    .test.assert.equals["Basic ",.Q.btoa "user:pass"; .http.auth.basic["user"; "pass"]];
 };
