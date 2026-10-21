// qbase Tests - http.status (HTTP status code descriptions)
// Copyright (c) 2026 Evgen Bielozorov
// Licensed under the Apache License, Version 2.0

// NOTE: 'http.status.q' has no explicit '.require.lib' call of its own - it is discovered and
// loaded alongside 'http.q' as part of the 'http' library's own file set (require matches any
// file named "http.*.q" as well as "http.q" for the 'http' lib), so loading 'http' is enough to
// make '.http.status' available - confirmed empirically: '.require.lib`http`' loads both
// 'src/http.q' and 'src/http.status.q'.
.require.lib`http;


.t.httpstatus_knownCodesResolveToExactStrings:{[]
    .test.assert.equals["OK"; .http.status 200];
    .test.assert.equals["Not Found"; .http.status 404];
    .test.assert.equals["Internal Server Error"; .http.status 500];
    .test.assert.equals["I'm a teapot"; .http.status 418];
 };

.t.httpstatus_hasMoreThanFiftyEntries:{[]
    .test.assert.true[50 < count .http.status];
 };

.t.httpstatus_unmappedCodeReturnsEmptyString:{[]
    / Empirically determined: '.http.status' is a plain (non-keyed-table) dictionary, so indexing
    / an int key with no entry (999 is not assigned in src/http.status.q) returns the null fill
    / for its string value domain, which is the empty string "" - not an error
    .test.assert.equals[""; .http.status 999];
 };
