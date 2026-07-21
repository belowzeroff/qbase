// qbase Tests - py (PyKX integration guard)
// Copyright (c) 2026 Evgen Bielozorov
// Licensed under the Apache License, Version 2.0

// PyKX is not installed in the test environment, so these verify the guard: the
// module loads cleanly and every function fails fast with a clear exception.

.require.lib`py;


.t.py_notAvailableByDefault:{[]
    .test.assert.false[.py.i.isAvailable[]];
    .test.assert.false[.py.cfg.enabled];
 };

.t.py_evalRaisesWhenDisabled:{[]
    .test.assert.raisesLike[.py.eval; enlist "1+1"; "*PyKxNotAvailable*"];
 };

.t.py_importRaisesWhenDisabled:{[]
    .test.assert.raisesLike[.py.import; enlist `os; "*PyKxNotAvailable*"];
 };
