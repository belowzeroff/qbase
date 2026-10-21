# slack

Sends a message to a Slack channel via an incoming webhook.

```q
.slack.notify[username; slackHookUrl; messageBody]  / post a message to Slack
```

`username` defaults to `user@host` if empty. The webhook URL contains a secret token, so
by default (`.slack.cfg.logWebhookUrl:0b`) it's masked in logs — the scheme and host stay
visible, everything after is replaced with asterisks; set the config to `1b` to log it in
full. The HTTP POST runs through `.ns.protectedExecute`, so a failed send returns `0b`
(and logs a warning) rather than raising.
