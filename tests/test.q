// qbase Test Framework
// Copyright (c) 2026 Evgen Bielozorov
// Licensed under the Apache License, Version 2.0

// A lightweight assertion + runner framework with no dependencies beyond base q.
//
// Test cases are niladic functions defined in the '.t' namespace, e.g.:
//     .t.cargs_parsesPort:{[] .test.assert.equals["5000"; .cargs.i.parse[...]`port] };
//
// Assertions throw an 'AssertionError on failure; the runner (.test.run) catches,
// records and reports each case. '.test.runAllAndExit' exits the process with the
// number of failed tests, so it can gate CI.


// -- Assertions ---------------------------------------------------------------

.test.i.fail:{[msg; expected; actual]
    '"AssertionError: ",msg," [ Expected: ",(-3!expected)," ] [ Actual: ",(-3!actual)," ]";
 };

/  @throws AssertionError If 'cond' is not identically true (1b)
.test.assert.true:{[cond]
    if[not 1b~cond; '"AssertionError: expected 1b but got ",-3!cond];
    1b };

/  @throws AssertionError If 'cond' is not identically false (0b)
.test.assert.false:{[cond]
    if[not 0b~cond; '"AssertionError: expected 0b but got ",-3!cond];
    1b };

/  @throws AssertionError If 'expected' and 'actual' do not match (~)
.test.assert.equals:{[expected; actual]
    if[not expected~actual; .test.i.fail["values not equal"; expected; actual]];
    1b };

/  @throws AssertionError If 'a' and 'b' match (~)
.test.assert.notEquals:{[a; b]
    if[a~b; '"AssertionError: expected values to differ but both were ",-3!a];
    1b };

/ Applies 'func' to the argument list 'args' (via apply) and asserts it throws
/  @param func (Function) The function to invoke
/  @param args (List) The arguments, applied with '.' (use 'enlist x' for a single argument)
/  @throws AssertionError If the function does not throw
.test.assert.raises:{[func; args]
    res:@[{[f; a] f . a; `NO_ERROR}[func;]; args; {[e] `RAISED}];
    if[not `RAISED~res; '"AssertionError: expected an exception but none was raised"];
    1b };

/ As '.test.assert.raises' but additionally checks the exception text matches 'pattern' (via like)
/  @throws AssertionError If the function does not throw, or the exception text does not match
.test.assert.raisesLike:{[func; args; pattern]
    res:@[{[f; a] f . a; ""}[func;]; args; {[e] $[0 = count e; " "; e]}];
    if[""~res; '"AssertionError: expected an exception but none was raised"];
    if[not res like pattern; '"AssertionError: exception text \"",res,"\" did not match \"",pattern,"\""];
    1b };


// -- Runner -------------------------------------------------------------------

/ The results of the most recent run (populated by '.test.run')
.test.results:();

/  @returns (SymbolList) The niladic test functions defined in the '.t' namespace
.test.i.discover:{
    names:key `.t;
    if[0 = count names; :`symbol$()];
    :names where 100h = type each get each ` sv/: `.t,/:names;
 };

/ Runs a single test case, capturing pass/fail, elapsed time and any error
.test.i.runOne:{[name]
    func:get ` sv `.t,name;
    st:.z.p;
    res:.Q.trp[{[fn] fn[]; (`PASS; "")}; func; {[err; bt] (`FAIL; err)}];
    elapsed:.z.p - st;

    -1 "  [",string[res 0],"] ",string[name],$[`FAIL ~ res 0; " -> ",res 1; ""];

    :`name`status`elapsed`error!(name; res 0; elapsed; res 1);
 };

/ Discovers, runs and reports every test case in the '.t' namespace
/  @returns (Table) One row per test with name, status, elapsed time and error
.test.run:{
    names:.test.i.discover[];
    sep:40#"-";

    -1 "";
    -1 "Running ",string[count names]," qbase test(s)";
    -1 sep;

    rows:.test.i.runOne each names;

    t:$[0 = count rows;
        ([] name:`symbol$(); status:`symbol$(); elapsed:`timespan$(); error:());
        flip `name`status`elapsed`error!flip value each rows
    ];

    .test.results:t;

    fails:count select from t where status = `FAIL;

    -1 sep;
    -1 "Result: ",string[count t]," run | ",string[count[t] - fails]," passed | ",string[fails]," failed | ",string[sum t`elapsed];
    -1 "";

    :t;
 };

/ Runs all tests and exits the process with the number of failures (capped at 255) - for CI
.test.runAllAndExit:{
    t:.test.run[];
    exit "i"$255 & count select from t where status = `FAIL;
 };
