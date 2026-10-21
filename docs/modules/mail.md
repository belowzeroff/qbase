# mail

Sends e-mail (including HTML bodies and attachments) by shelling out to `mailx` or
`mutt`.

```q
.mail.send[dict]  / required: subject, to. optional: cc, bcc, body, attachments, from, useMailCmd
```

The process blocks until the underlying mail command returns. Required keys missing from
`dict` raise `MissingArgumentException`; an attachment path containing a space raises
`InvalidEmailAttachmentPathException` (not supported); an unavailable `useMailCmd` raises
`InvalidMailCommandException`; and a non-zero exit from the mail command raises
`EmailSendFailedException`. Subject, body, addresses and attachment paths are all
single-quote-escaped before being shelled out (see the project's top-level Security
notes) — available commands are auto-detected on init from the `.mail.i.send.*`
namespace (currently `mailx` and `mutt`).
