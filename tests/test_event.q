// qbase Tests - event (internal event management)
// Copyright (c) 2026 Evgen Bielozorov
// Licensed under the Apache License, Version 2.0

.require.lib`event;


/ Call log + handler stubs for exercising '.event.addListener' / '.event.fire' /
/ '.event.removeListener' directly. Reset at the start of each test case that uses it
.t.i.eventCalls:();

.t.i.eventHandlerA:{[args] .t.i.eventCalls,:enlist (`A; args); };
.t.i.eventHandlerB:{[args] .t.i.eventCalls,:enlist (`B; args); };


.t.event_addListener_fireCallsHandlerWithArgs:{[]
    .t.i.eventCalls:();

    .event.addListener[`t.testEventA; `.t.i.eventHandlerA];
    .event.fire[`t.testEventA; `someArg];

    .test.assert.equals[enlist (`A; `someArg); .t.i.eventCalls];

    .event.removeListener[`t.testEventA; `.t.i.eventHandlerA];
 };

.t.event_fire_multipleHandlersAllFire:{[]
    .t.i.eventCalls:();

    .event.addListener[`t.testEventB; `.t.i.eventHandlerA];
    .event.addListener[`t.testEventB; `.t.i.eventHandlerB];
    .event.fire[`t.testEventB; 42];

    .test.assert.equals[2; count .t.i.eventCalls];
    .test.assert.true[(`A; 42) in .t.i.eventCalls];
    .test.assert.true[(`B; 42) in .t.i.eventCalls];

    .event.removeListener[`t.testEventB; `.t.i.eventHandlerA];
    .event.removeListener[`t.testEventB; `.t.i.eventHandlerB];
 };

.t.event_removeListener_stopsHandlerFiring:{[]
    .t.i.eventCalls:();

    .event.addListener[`t.testEventC; `.t.i.eventHandlerA];
    .event.removeListener[`t.testEventC; `.t.i.eventHandlerA];
    .event.fire[`t.testEventC; `x];

    .test.assert.equals[0; count .t.i.eventCalls];
 };

.t.event_fire_noHandlersDoesNotRaise:{[]
    .test.assert.equals[(::); .event.fire[`t.testEventWithNoHandlers; `anything]];
 };
