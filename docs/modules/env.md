# env

Environment variable access and `.env`-style file loading.

```q
.env.get[envVar]    / cached or live (getenv) environment variable value
.env.which[cmd]      / full path of a command as found on $PATH
.env.load[path]      / load KEY=VALUE pairs from a .env file into the cache
```

`QHOME`, `QLIC`, `PATH` and the OS's shared-object path variable are pre-parsed into
`.env.cache` on init (`.env.cfg.vars`); anything else is fetched live via `getenv` on
first `.env.get` and throws `EnvironmentVariableNotDefinedException` if unset.
`.env.which` throws `CommandNotFoundException` if the command isn't found on `$PATH`.
`.env.load` throws `DotEnvFileNotFoundException` for a missing file; it skips blank lines
and `#` comments, strips a leading `export `, and removes one matching pair of
surrounding quotes from each value.

```q
q).env.load `:.env
FOO| "bar"
BAZ| "qux"
```
