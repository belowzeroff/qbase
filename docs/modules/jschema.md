# jschema

Lightweight structural validation for JSON values already parsed with `.j.k`.

```q
.jschema.validate[schema; obj]  / validate, throwing SchemaValidationException on failure
.jschema.isValid[schema; obj]   / validate, returning a boolean instead of throwing
```

A schema is a dictionary: `` `type `` is one of
`` `dict`list`string`symbol`long`float`number`boolean`any ``; `` `required `` lists keys a
`` `dict `` must contain; `` `fields `` maps keys to sub-schemas checked when present;
`` `items `` is a sub-schema applied to every element of a `` `list ``. `.jschema.validate`
reports the failing path (e.g. `$.name` or `$.items[2]`) in the exception message.

```q
q)schema:`type`required`fields!(`dict; `name`age; `name`age!(enlist[`type]!enlist`string; enlist[`type]!enlist`number))
q).jschema.isValid[schema; `name`age!("Alice"; 30f)]
1b
```
