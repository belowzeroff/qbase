// qbase Tests - convert (type conversion functions)
// Copyright (c) 2026 Evgen Bielozorov
// Licensed under the Apache License, Version 2.0

.require.lib`convert;


// -- .convert.msToTimespan / .convert.timespanToMs --------------------------------

.t.convert_msToTimespan_happyPath:{[]
    .test.assert.equals[0D00:00:01.000000000; .convert.msToTimespan 1000];
 };

.t.convert_msToTimespan_zero:{[]
    .test.assert.equals[0D00:00:00.000000000; .convert.msToTimespan 0];
 };

.t.convert_timespanToMs_happyPath:{[]
    .test.assert.equals[1000; .convert.timespanToMs 0D00:00:01];
 };

.t.convert_timespanToMs_zero:{[]
    .test.assert.equals[0; .convert.timespanToMs 0D00:00:00];
 };


// -- .convert.hsymToString / .convert.stringToHsym ---------------------------------

.t.convert_hsymToString_happyPath:{[]
    .test.assert.equals["/tmp/foo"; .convert.hsymToString `:/tmp/foo];
 };

.t.convert_hsymToString_rootPath:{[]
    .test.assert.equals[""; .convert.hsymToString `:];
 };

.t.convert_stringToHsym_happyPath:{[]
    .test.assert.equals[`:/tmp/foo; .convert.stringToHsym "/tmp/foo"];
 };

.t.convert_stringToHsym_emptyString:{[]
    .test.assert.equals[`; .convert.stringToHsym ""];
 };


// -- .convert.ipOctalToSymbol -------------------------------------------------------

.t.convert_ipOctalToSymbol_happyPath:{[]
    .test.assert.equals[`127.0.0.1; .convert.ipOctalToSymbol 2130706433i];
 };

.t.convert_ipOctalToSymbol_allZeroes:{[]
    .test.assert.equals[`0.0.0.0; .convert.ipOctalToSymbol 0i];
 };


// -- .convert.listToString ----------------------------------------------------------

.t.convert_listToString_happyPath:{[]
    .test.assert.equals["1, 2, 3"; .convert.listToString (1; 2; 3)];
 };

.t.convert_listToString_singleElement:{[]
    / NOTE: the 1-char result is a char VECTOR (not the char ATOM a bare "5" literal would
    / parse as), hence the explicit 'enlist' to construct the expected vector
    .test.assert.equals[enlist "5"; .convert.listToString enlist 5];
 };
