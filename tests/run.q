// qbase Test Runner
// Copyright (c) 2026 Evgen Bielozorov
// Licensed under the Apache License, Version 2.0

// Loaded after boot.q (which initialises require + the core libraries). This
// script loads the '.test' framework and every tests/test_*.q case file, runs
// them and exits with the number of failures.
//
// Run it with:  q boot.q < tests/run.q     (or use tests/run.sh)


.test.i.root:.boot.root.kdbCommon;

/ Load the assertion + runner framework
system "l ",1_ string ` sv .test.i.root,`tests`test.q;

/ Discover and load all test case files (tests/test_*.q)
.test.i.testDir:` sv .test.i.root,`tests;
.test.i.caseFiles:` sv/: .test.i.testDir,/:(k) where (k:key .test.i.testDir) like "test_*.q";

{ system "l ",1_ string x } each .test.i.caseFiles;

/ Run everything and exit with the failure count
.test.runAllAndExit[];
