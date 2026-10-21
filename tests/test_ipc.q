// qbase Tests - ipc (inter-process communication)
// Copyright (c) 2026 Evgen Bielozorov
// Licensed under the Apache License, Version 2.0

// NOTE: kdb+ is single-threaded, so a process that both listens on a port and synchronously
// connects back to itself can deadlock. These tests therefore never call '\p', never call
// '.ipc.connectWait'/'.ipc.oneShotWait' (infinite timeout) and the only live network calls made
// are to a localhost port that nothing is listening on, with an explicit short timeout - a
// refused connection fails fast (sub-second) rather than hanging. Everything else exercises pure
// logic / table bookkeeping with no connection attempted at all.

.require.lib`ipc;


// -- .ipc.i.normaliseHostPort -------------------------------------------------

.t.ipc_normaliseHostPort_returnsExpectedKeys:{[]
    res:.ipc.i.normaliseHostPort `:remotehost.invalid:5000;

    .test.assert.equals[`original`toConnect`toLog; key res];
 };

/ A non-local host/port with no user/password should pass through unchanged in all 3 fields
/ (modulo UDS translation, which only applies to hosts in '.ipc.localhostAddresses')
.t.ipc_normaliseHostPort_nonLocalHostPassesThroughUnchanged:{[]
    hp:`:remotehost.invalid:5000;
    res:.ipc.i.normaliseHostPort hp;

    .test.assert.equals[hp; res`original];
    .test.assert.equals[hp; res`toConnect];
    .test.assert.equals[string hp; res`toLog];
 };

/ macOS ('m') is in '.ipc.udsSupportedOs', so UDS is very likely enabled here - but check the live
/ value rather than assume, so this still passes (trivially) on an OS/config where it is not
.t.ipc_normaliseHostPort_localhostTranslatedToUdsWhenEnabled:{[]
    if[not .ipc.udsEnabled;
        :1b
    ];

    hp:`:localhost:40000;
    res:.ipc.i.normaliseHostPort hp;

    .test.assert.equals[hp; res`original];
    / 'toConnect' is always a symbol; 'toLog' is already a plain string (built via 'string' on the
    / connect symbol inside the function under test), so it must not be re-stringified here
    .test.assert.true[string[res`toConnect] like ":unix://*"];
    .test.assert.true[res[`toLog] like ":unix://*"];
 };

/ '.ipc.cfg.logPasswordsDuringConnect' defaults to 0b, so a 4-colon host/port/user/password form
/ must have its password masked (with count-matching asterisks) in 'toLog' only - 'toConnect' and
/ 'original' must retain the real password unmasked
.t.ipc_normaliseHostPort_passwordMaskedInLogOnly:{[]
    hp:`:127.0.0.1:40000:myuser:mypassword;
    res:.ipc.i.normaliseHostPort hp;
    mask:count["mypassword"]#"*";

    / 'original' and 'toConnect' are symbols here; 'toLog' is already a plain string. NOTE: can't
    / use 'like' with a pattern built from the literal "*" mask chars themselves (a wildcard "*"
    / directly followed by literal "*" chars raises 'nyi in kdb's 'like' - so the mask-suffix check
    / below compares the last N characters directly instead)
    .test.assert.true[string[res`original] like "*mypassword"];
    .test.assert.true[string[res`toConnect] like "*mypassword"];
    .test.assert.equals[mask; neg[count mask] sublist res`toLog];
    .test.assert.false[res[`toLog] like "*mypassword"];
 };

/ A short (not long) atom is not a valid HostPort type ('.type.isHostPort' only treats a LONG atom
/ as a bare-port shorthand), so this must fail the type check before anything else happens
.t.ipc_normaliseHostPort_invalidTypeRaises:{[]
    .test.assert.raisesLike[.ipc.i.normaliseHostPort; enlist 5000h; "IllegalArgumentException*"];
 };


// -- .ipc.getHandlesFor --------------------------------------------------------

/ 999001 is an arbitrary, obviously-fake handle used only to seed '.ipc.outbound' directly. Real
/ outbound handles in this test process (which never makes a successful live connection) are
/ either absent entirely or small positive integers, so this value cannot collide with one
.t.ipc_getHandlesFor_returnsHandleForMatchingHostPort:{[]
    fakeHandle:999001j;
    testHostPort:`:faketesthost.invalid:59999;
    hpHash:.Q.sha1 .type.ensureString (.ipc.i.normaliseHostPort testHostPort)`original;

    `.ipc.outbound upsert (fakeHandle; `$string testHostPort; .time.now[]; hpHash);

    found:@[.ipc.getHandlesFor; testHostPort; {[e] `long$()}];

    delete from `.ipc.outbound where handle = fakeHandle;

    .test.assert.true[fakeHandle in found];
 };


// -- .ipc.i.connectionOpen / .ipc.i.connectionClosed --------------------------

.t.ipc_connectionOpen_addsInboundRow:{[]
    fakeHandle:999002j;

    / '.ipc.i.connectionOpen' takes 2 args, so the protected multi-arg form is '.[f;argList;errFn]',
    / NOT '@[f;argList;errFn]' (the latter would pass 'argList' as a single first arg, i.e. a
    / 1-arg projection, which never errors and so never actually calls the function)
    .[.ipc.i.connectionOpen; (fakeHandle; `tcp); {[e] (::)}];

    present:fakeHandle in key .ipc.inbound;

    delete from `.ipc.inbound where handle = fakeHandle;

    .test.assert.true[present];
 };

.t.ipc_connectionClosed_removesInboundRow:{[]
    fakeHandle:999003j;

    .[.ipc.i.connectionOpen; (fakeHandle; `tcp); {[e] (::)}];
    wasAdded:fakeHandle in key .ipc.inbound;

    @[.ipc.i.connectionClosed; fakeHandle; {[e] (::)}];
    stillPresent:fakeHandle in key .ipc.inbound;

    / Safety-net cleanup in case the function under test failed to remove it
    delete from `.ipc.inbound where handle = fakeHandle;

    / Confirm the row genuinely existed before close was called - otherwise an absent row would
    / trivially (and wrongly) satisfy the 'removed' assertion below
    .test.assert.true[wasAdded];
    .test.assert.false[stillPresent];
 };

/ A handle can appear in either '.ipc.inbound' or '.ipc.outbound' - '.ipc.i.connectionClosed'
/ checks (and removes from) both
.t.ipc_connectionClosed_removesOutboundRow:{[]
    fakeHandle:999004j;

    `.ipc.outbound upsert (fakeHandle; `faketarget; .time.now[]; `fakehash);
    @[.ipc.i.connectionClosed; fakeHandle; {[e] (::)}];

    stillPresent:fakeHandle in key .ipc.outbound;

    / Safety-net cleanup in case the function under test failed to remove it
    delete from `.ipc.outbound where handle = fakeHandle;

    .test.assert.false[stillPresent];
 };


// -- .ipc.connectWithTimeout / .ipc.oneShotWithTimeout - argument validation -

/ Timeout validation is the first thing both functions do - a bad timeout must fail before any
/ host/port handling or 'hopen' is ever reached
.t.ipc_connectWithTimeout_nonLongTimeoutRaises:{[]
    .test.assert.raisesLike[.ipc.connectWithTimeout; (`:localhost:54321; 1000h); "IllegalArgumentException*"];
 };

.t.ipc_connectWithTimeout_negativeTimeoutRaises:{[]
    .test.assert.raisesLike[.ipc.connectWithTimeout; (`:localhost:54321; -1); "IllegalArgumentException*"];
 };

.t.ipc_oneShotWithTimeout_nonLongTimeoutRaises:{[]
    .test.assert.raisesLike[.ipc.oneShotWithTimeout; (`:localhost:54321; 1000h; "1+1"); "IllegalArgumentException*"];
 };

.t.ipc_oneShotWithTimeout_negativeTimeoutRaises:{[]
    .test.assert.raisesLike[.ipc.oneShotWithTimeout; (`:localhost:54321; -1; "1+1"); "IllegalArgumentException*"];
 };


// -- Live network: refused connection on a localhost port nothing listens on -

/ Port 54321 - confirmed (via 'lsof'/'nc') to have nothing listening on it on the machine these
/ tests were authored on. A refused connection (or, when UDS is enabled, a missing UDS socket
/ file) fails near-instantly rather than hanging, which the elapsed-time assertion below confirms
.t.ipc_connectWithTimeout_refusedConnectionFailsFast:{[]
    st:.z.p;
    res:@[.ipc.connectWithTimeout[`:localhost:54321;]; 1000; {[e] (`CAUGHT; e)}];
    elapsed:.z.p - st;

    .test.assert.true[`CAUGHT ~ first res];
    .test.assert.true[(last res) like "ConnectionFailedException*"];
    .test.assert.true[elapsed < 0D00:00:05];
 };

.t.ipc_oneShotWithTimeout_refusedConnectionFailsFast:{[]
    st:.z.p;
    res:@[.ipc.oneShotWithTimeout[`:localhost:54321; 1000;]; "1+1"; {[e] (`CAUGHT; e)}];
    elapsed:.z.p - st;

    .test.assert.true[`CAUGHT ~ first res];
    .test.assert.true[(last res) like "OneShotFailedException*"];
    .test.assert.true[elapsed < 0D00:00:05];
 };
