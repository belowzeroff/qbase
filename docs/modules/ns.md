# ns

Namespace introspection and protected execution helpers.

```q
.ns.get[ns]                    / fully-qualified contents of a namespace
.ns.flatten[ns]                / recurse into child namespaces too
.ns.resolveFunctionName[func]  / function body -> its declared name, if resolvable
.ns.isSet[x]                   / does the reference exist?
.ns.protectedExecute[func; args] / try/catch a function call, args as (::) if none
.ns.executeFuncWithDict[func; args] / call a function from a dict keyed by argument name
```

`.ns.protectedExecute` uses `-105!` (`.Q.trp`) for an error stack when
`.ns.cfg.protectExecWithStack` is enabled (kdb+ >= 3.5, set automatically on init);
otherwise it falls back to plain `@` protected execution. On failure it returns a dict
with `isError` set to `` `PROT_EXEC_FAILED `` plus `errorMsg` (and `backtrace` with the
stack-trace variant). `.ns.executeFuncWithDict` throws `MissingFunctionArgumentException`
if any expected argument is absent from the supplied dict.
