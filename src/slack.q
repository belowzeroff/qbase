// Slack Notification Integration via WebHook
// Copyright (c) 2019 Sport Trades Ltd
// Copyright (c) 2026 Evgen Bielozorov
// Licensed under the Apache License, Version 2.0

// Documentation: https://github.com/BuaBook/kdb-common/wiki/slack.q

.require.lib each `type`ns;

// NOTE: Depending on your OS, you might need to update the location of the SSL certificates on your machine.
// For example, on Bash on Windows, you'll need to run: export SSL_CA_CERT_PATH=/etc/ssl/certs
// Or you can simply disable server verification with: export SSL_VERIFY_SERVER=NO

/ Whether the Slack hook URL, which contains a secret token, should be logged in full. If false
/ (the default), the URL will be masked for logging - the scheme and host are kept visible and
/ everything after the host (the webhook's secret path) is replaced with asterisks. If true, the
/ plain-text URL will be logged
/  @see .slack.i.maskUrl
.slack.cfg.logWebhookUrl:0b;


/ Sends a message to Slack
/  @param username (String) The username to show the message as coming from (this does not have to be a real Slack user). If none is specified, it will default to user@host
/  @param slackHookUrl (String) The Slack hook URL to use to send the message to
/  @param messageBody (String) The body of the message to send to Slack
/  @returns (Boolean) True if the message was sent successfully, false otherwise. All exceptions from the underlying system command are suppressed
/  @see .Q.hp
/  @see .slack.cfg.logWebhookUrl
.slack.notify:{[username; slackHookUrl; messageBody]
    username:.type.ensureString username;

    if[.util.isEmpty slackHookUrl;
        '"IllegalArgumentException";
    ];

    if[.util.isEmpty username;
        username:"@" sv string each (.z.u;.z.h);
    ];

    slackWebhookDict:`text`username!(messageBody; username);

    logHookUrl:$[.slack.cfg.logWebhookUrl; slackHookUrl; .slack.i.maskUrl slackHookUrl];

    .log.if.info  "Sending Slack notification [ Username: ",username," ] [ Message: ",.Q.s1[slackWebhookDict]," ]";
    .log.if.debug " [ Slack Hook URL: ",logHookUrl," ]";

    slackPostResult:.ns.protectedExecute[`.Q.hp; (slackHookUrl; "application/json"; .j.j slackWebhookDict)];

    if[.ns.const.pExecFailure ~ first slackPostResult;
        .log.if.warn "Failed to send Slack notification [ Username: ",username," ] [ Slack Hook URL: ",logHookUrl," ]. Error - ",last slackPostResult;
        :0b;
    ];

    :1b;
 };

/ Masks a Slack webhook URL for safe logging - the scheme and host are kept visible and
/ everything after the host (the webhook's secret path/token) is replaced with asterisks of
/ the same length, mirroring the masking style used by .ipc.i.normaliseHostPort for passwords
/  @param url (String) The Slack hook URL to mask
/  @returns (String) The URL with everything after the host replaced with asterisks. If the URL
/   has no path (just a scheme and host), it is returned unchanged
.slack.i.maskUrl:{[url]
    parts:"/" vs url;

    if[count[parts] <= 3;
        :url;
    ];

    hostPart:"/" sv 3#parts;
    maskedPath:count["/" sv 3_parts]#"*";

    :hostPart,"/",maskedPath;
 };
