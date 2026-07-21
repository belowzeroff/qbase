// qbase Tests - parquet (arrowkdb guard)
// Copyright (c) 2026 Evgen Bielozorov
// Licensed under the Apache License, Version 2.0

// arrowkdb is not installed in the test environment, so these verify the guard.

.require.lib`parquet;


.t.parquet_notAvailableByDefault:{[]
    .test.assert.false[.parquet.i.isAvailable[]];
    .test.assert.false[.parquet.cfg.enabled];
 };

.t.parquet_readRaisesWhenDisabled:{[]
    .test.assert.raisesLike[.parquet.read; enlist `:/tmp/x.parquet; "*ArrowKdbNotAvailable*"];
 };
