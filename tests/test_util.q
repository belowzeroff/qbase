// qbase Tests - util (misc utility functions)
// Copyright (c) 2026 Evgen Bielozorov
// Licensed under the Apache License, Version 2.0


.t.util_trimEmptyStringReturnsEmpty:{[]
    .test.assert.equals[""; .util.trim ""];
 };

.t.util_trimAllWhitespaceReturnsEmpty:{[]
    .test.assert.equals[""; .util.trim "  \t\n\r "];
 };

.t.util_trimStripsSurroundingWhitespace:{[]
    .test.assert.equals["a b"; .util.trim "  a b \n"];
 };

.t.util_trimLeavesNoSurroundingWhitespaceUnchanged:{[]
    .test.assert.equals["a b"; .util.trim "a b"];
 };
