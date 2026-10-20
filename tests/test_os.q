// qbase Tests - os (OS command templates & shell-argument escaping)
// Copyright (c) 2026 Evgen Bielozorov
// Licensed under the Apache License, Version 2.0

.require.lib`os;


// -- .os.i.escapeSQ -----------------------------------------------------------

.t.os_escapeSQ_wrapsPlainString:{[]
    .test.assert.equals["'hello'"; .os.i.escapeSQ "hello"];
 };

.t.os_escapeSQ_escapesEmbeddedSingleQuote:{[]
    .test.assert.equals["'a'\\''b'"; .os.i.escapeSQ "a'b"];
 };

.t.os_escapeSQ_emptyString:{[]
    .test.assert.equals["''"; .os.i.escapeSQ ""];
 };

/ A string containing a mix of shell metacharacters (backtick, semicolon, $(), spaces) and an
/ embedded single quote must come back as exactly one safely single-quoted token with no
/ unescaped single quote left inside it
.t.os_escapeSQ_metacharactersProduceOneSafeToken:{[]
    nasty:"`;$() foo's bar";
    escaped:.os.i.escapeSQ nasty;
    nQuotes:count ss[nasty; "'"];

    .test.assert.equals["'"; first escaped];
    .test.assert.equals["'"; last escaped];
    / Each embedded ' becomes '\'' (net +3 chars); +2 for the outer wrapping quotes
    .test.assert.equals[count[nasty] + 2 + 3*nQuotes; count escaped];
 };


// -- Regression: shell injection via .os.l.mkdir / .os.m.mkdir is closed -----

/ Builds a directory name which, if spliced unescaped into "mkdir -p <name>" (the old,
/ vulnerable behaviour), would use shell backtick command substitution to run an arbitrary
/ command - here, creating a sentinel file - before the (now-empty) substitution result was
/ used as the actual mkdir argument. With the fix, the whole name is single-quote-wrapped, so
/ the backticks are inert literal characters and the sentinel is never created.
.t.os_mkdir_blocksShellInjection:{[]
    sentinel:`:/tmp/qbase_pwn_proof;
    topLevelDir:"/tmp/qbase_test_pwn_dir`touch ";
    payload:topLevelDir,"/tmp/qbase_pwn_proof`";

    / Guarded so a failing assertion below still runs the cleanup that follows it
    @[{[p] .os.run[`mkdir; p]}; payload; {[e] (::)}];

    pwned:.type.isFile sentinel;

    / Clean up the directory tree mkdir created (via the now-safe .os.run[`rmFolder;...] path)
    / and the sentinel file, if it was wrongly created, regardless of the assertion outcome
    @[{[d] .os.run[`rmFolder; d]}; topLevelDir; {[e] (::)}];
    if[.type.isFile sentinel; hdel sentinel];

    .test.assert.false pwned;
 };
