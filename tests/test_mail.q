// qbase Tests - mail (shell-safe command building for .mail.i.send.*)
// Copyright (c) 2026 Evgen Bielozorov
// Licensed under the Apache License, Version 2.0

// NOTE: These tests only exercise the pure string-building functions .mail.i.send.mailx /
// .mail.i.send.mutt - they never call .mail.send / .util.system, so no real e-mail is sent.

.require.lib`mail;


// -- Regression: subject containing a double-quote + shell metacharacters is safe ----------

/ Before the fix, the subject was spliced into a DOUBLE-quoted "-s \"...\"" fragment with no
/ escaping, so a subject containing '"' could break out and inject arbitrary shell commands
/ (e.g. "; touch /tmp/qbase_mail_pwn; echo "). After the fix, the whole subject is a single
/ single-quoted token, so the subject must now appear immediately after "-s '" (not "-s \"")
/ and there must be no "-s \"" fragment left in the command at all.
.t.mail_mailx_subjectWithQuoteAndSemicolonIsSingleQuoted:{[]
    dict:`subject`to!("hello\"; touch /tmp/qbase_mail_pwn; echo \"done"; `$"victim@example.com");
    result:.mail.i.send.mailx dict;

    .test.assert.true[0 < count ss[result; "-s '"]];
    .test.assert.equals[0; count ss[result; "-s \""]];
 };

.t.mail_mutt_subjectWithQuoteAndSemicolonIsSingleQuoted:{[]
    dict:`subject`to!("hello\"; touch /tmp/qbase_mail_pwn; echo \"done"; `$"victim@example.com");
    result:.mail.i.send.mutt dict;

    .test.assert.true[0 < count ss[result; "-s '"]];
    .test.assert.equals[0; count ss[result; "-s \""]];
 };


// -- Regression: 'from' containing a single quote is escaped, not left unescaped -----------

/ An embedded single quote in 'from' must be escaped as '\'' (closing quote, escaped literal
/ quote, reopening quote) rather than left as a bare quote that would break out of the
/ surrounding single-quoted header fragment
.t.mail_mailx_fromWithEmbeddedQuoteIsEscaped:{[]
    dict:`subject`to`from!("Safe subject"; `$"victim@example.com"; `$"o'brien@example.com");
    result:.mail.i.send.mailx dict;

    .test.assert.true[0 < count ss[result; "'\\''"]];
 };

.t.mail_mutt_fromWithEmbeddedQuoteIsEscaped:{[]
    dict:`subject`to`from!("Safe subject"; `$"victim@example.com"; `$"o'brien@example.com");
    result:.mail.i.send.mutt dict;

    .test.assert.true[0 < count ss[result; "'\\''"]];
 };


// -- Sanity: a normal, legitimate e-mail still produces a sane, well-formed command ---------

.t.mail_mailx_normalEmailProducesSaneCommand:{[]
    dict:`subject`to`cc`from!("Hello World"; `$"alice@example.com"; `$"bob@example.com"; `$"sender@example.com");
    result:.mail.i.send.mailx dict;

    .test.assert.true[0 < count ss[result; "mailx -s 'Hello World'"]];
    .test.assert.true[0 < count ss[result; "'alice@example.com'"]];
 };

.t.mail_mutt_normalEmailProducesSaneCommand:{[]
    dict:`subject`to`cc`from!("Hello World"; `$"alice@example.com"; `$"bob@example.com"; `$"sender@example.com");
    result:.mail.i.send.mutt dict;

    .test.assert.true[0 < count ss[result; "mutt -s 'Hello World'"]];
    .test.assert.true[0 < count ss[result; "'alice@example.com'"]];
 };
