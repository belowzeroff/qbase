// qbase Tests - env (.env file loading)
// Copyright (c) 2026 Evgen Bielozorov
// Licensed under the Apache License, Version 2.0

.require.lib`env;


.t.env_loadsDotEnvFile:{[]
    path:`:/tmp/qbase_test_env.env;
    path 0: ("# a comment"; "FOO=bar"; ""; "export BAZ=qux"; "QUOTED=\"hello world\""; "URL=http://x?a=b");
    parsed:.env.load path;
    hdel path;

    .test.assert.equals["bar"; parsed`FOO];
    .test.assert.equals["qux"; parsed`BAZ];
    .test.assert.equals["hello world"; parsed`QUOTED];
    .test.assert.equals["http://x?a=b"; parsed`URL];
 };

.t.env_loadedValuesAvailableViaGet:{[]
    path:`:/tmp/qbase_test_env2.env;
    path 0: enlist "MY_SETTING=42";
    .env.load path;
    hdel path;

    .test.assert.equals["42"; .env.get `MY_SETTING];
 };

.t.env_missingFileRaises:{[]
    .test.assert.raisesLike[.env.load; enlist `:/tmp/does_not_exist_qbase.env; "*DotEnvFileNotFound*"];
 };

.t.env_parseLineStripsExportAndQuotes:{[]
    .test.assert.equals[(`KEY; "val"); .env.i.parseLine "export KEY='val'"];
 };
