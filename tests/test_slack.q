// qbase Tests - slack (webhook URL masking for logging)
// Copyright (c) 2026 Evgen Bielozorov
// Licensed under the Apache License, Version 2.0

.require.lib`slack;


.t.slack_maskUrl_hostIntactPathMasked:{[]
    url:"https://hooks.slack.com/services/T000/B000/XXXXXXXX";
    masked:.slack.i.maskUrl url;

    .test.assert.equals["https://hooks.slack.com/"; (count "https://hooks.slack.com/")#masked];
    .test.assert.equals[0; count ss[masked; "services"]];
    .test.assert.equals[0; count ss[masked; "XXXXXXXX"]];
 };

.t.slack_cfg_logWebhookUrlDefaultsOff:{[]
    .test.assert.equals[0b; .slack.cfg.logWebhookUrl];
 };

.t.slack_cfg_logWebhookUrlTrueReturnsFullUrlUnmasked:{[]
    url:"https://hooks.slack.com/services/T000/B000/XXXXXXXX";
    orig:.slack.cfg.logWebhookUrl;

    .slack.cfg.logWebhookUrl:1b;
    logHookUrl:$[.slack.cfg.logWebhookUrl; url; .slack.i.maskUrl url];
    .slack.cfg.logWebhookUrl:orig;

    .test.assert.equals[url; logHookUrl];
 };
