// qbase Tests - wsc (WebSocket client)
// Copyright (c) 2026 Evgen Bielozorov
// Licensed under the Apache License, Version 2.0

// NOTE: Only the 3 validation/error paths of '.wsc.connect' that are reachable WITHOUT any real
// network connection are covered here, in the exact order they are checked:
//   1) non-string 'url'                      -> InvalidArgumentException
//   2) '.z.ws' not set                       -> ZWsHandlerNotSetException
//   3) bad URL scheme (with '.z.ws' set)     -> InvalidWebSocketUrlException
// The actual connection-success path and 'WebSocketConnectionFailedException' are intentionally
// NOT tested - that needs a real WS-capable network target and '.http.i.send''s exact timeout
// behaviour is unknown/unverified in this environment. This is a deliberate scope boundary.
//
// '.z.ws' cannot be removed with a plain 'delete'/amend ('![`.z;...]') - the '.z' pseudo-namespace
// rejects that and raises a '.z' error - so the system command '\x .z.ws' (variable expunge) is
// used instead to genuinely unset it, verified empirically to work and leave '.ns.isSet' as 0b
// afterwards. Both tests below save/restore whatever state '.z.ws' was actually found in, and do
// so even if the assertion itself fails, so a failure never leaks changed global state.

.require.lib`wsc;


// -- .wsc.connect --------------------------------------------------------------

.t.wsc_connect_nonStringUrlRaises:{[]
    .test.assert.raisesLike[.wsc.connect; enlist 123; "InvalidArgumentException*"];
 };

/ To reach 'ZWsHandlerNotSetException' cleanly, '.z.ws' must genuinely be unset beforehand. In
/ practice nothing in the require chain sets it ('.ns.isSet `.z.ws' is 0b on entry), but this
/ still saves/restores whatever state it finds, rather than assuming
.t.wsc_connect_zWsNotSetRaises:{[]
    hadZWs:.ns.isSet `.z.ws;
    savedZWs:$[hadZWs; .z.ws; (::)];

    if[hadZWs; system "x .z.ws"];

    / Run the assertion protected so a failure still restores state below instead of leaking it
    outcome:@[{[] .test.assert.raisesLike[.wsc.connect; enlist "ws://example.com"; "ZWsHandlerNotSetException*"] }; (::); {[e] e}];

    if[hadZWs; .z.ws:savedZWs];

    if[not 1b~outcome; 'outcome];
    1b
 };

/ To reach 'InvalidWebSocketUrlException', '.z.ws' must be set (to anything callable) first -
/ restore whatever '.z.ws' was before this test afterwards (unset it again via '\x' if it wasn't
/ set to begin with, so this test leaves no trace either way)
.t.wsc_connect_badSchemeRaises:{[]
    hadZWs:.ns.isSet `.z.ws;
    savedZWs:$[hadZWs; .z.ws; (::)];

    .z.ws:{[x]};

    outcome:@[{[] .test.assert.raisesLike[.wsc.connect; enlist "http://example.com"; "InvalidWebSocketUrlException*"] }; (::); {[e] e}];

    $[hadZWs; .z.ws:savedZWs; system "x .z.ws"];

    if[not 1b~outcome; 'outcome];
    1b
 };
