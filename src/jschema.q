// JSON Schema Validation
// Copyright (c) 2026 Evgen Bielozorov
// Licensed under the Apache License, Version 2.0

// Lightweight structural validation for JSON values parsed with '.j.k'. A schema
// is a dictionary describing the expected shape:
//   `type     (Symbol)      one of `dict`list`string`symbol`long`float`number`boolean`any
//   `required (SymbolList)  [dict]  keys that must be present
//   `fields   (Dict)        [dict]  key -> sub-schema, validated when the key is present
//   `items    (Dict)        [list]  sub-schema applied to every element

.require.lib`type;


/ Schema 'type' -> predicate against a '.j.k'-parsed value
.jschema.checkers:(`symbol$())!();
.jschema.checkers[`any]:     {[x] 1b};
.jschema.checkers[`dict]:    {[x] .type.isDict x};
.jschema.checkers[`list]:    {[x] (0h = type x) | (0 < type x) & not .type.isString x};
.jschema.checkers[`string]:  {[x] .type.isString x};
.jschema.checkers[`symbol]:  {[x] .type.isSymbol x};
.jschema.checkers[`long]:    {[x] -7h = type x};
.jschema.checkers[`float]:   {[x] -9h = type x};
.jschema.checkers[`number]:  {[x] (type x) in -7 -8 -9h};
.jschema.checkers[`boolean]: {[x] -1h = type x};


.jschema.init:{};


/ Validates a '.j.k'-parsed object against the schema
/  @param schema (Dict) The schema definition
/  @param obj () The parsed JSON value
/  @returns (Boolean) 1b if valid
/  @throws SchemaValidationException If the object does not conform (with the failing path and reason)
.jschema.validate:{[schema; obj]
    :.jschema.i.validateAt["$"; schema; obj];
 };

/ As '.jschema.validate' but returns a boolean instead of throwing
/  @returns (Boolean) 1b if valid, 0b otherwise
.jschema.isValid:{[schema; obj]
    :`VALID ~ @[{ .jschema.validate . x; `VALID }; (schema; obj); {[e] `INVALID}];
 };


.jschema.i.validateAt:{[path; schema; obj]
    st:schema`type;

    if[not st in key .jschema.checkers;
        '"SchemaValidationException (unknown schema type '",string[st],"' at ",path,")";
    ];

    if[not .jschema.checkers[st] obj;
        '"SchemaValidationException (expected ",string[st]," at ",path,", got q type ",string[type obj],")";
    ];

    if[st = `dict;
        if[`required in key schema;
            missing:schema[`required] except key obj;
            if[0 < count missing;
                '"SchemaValidationException (missing required key(s) ",(", " sv string missing)," at ",path,")";
            ];
        ];

        if[`fields in key schema;
            fields:schema`fields;
            fldKeys:key[fields] inter key obj;
            {[path; obj; k; fs] .jschema.i.validateAt[path,".",string k; fs; obj k] }[path; obj;;]'[fldKeys; fields fldKeys];
        ];
    ];

    if[st = `list;
        if[`items in key schema;
            items:schema`items;
            {[path; items; i; el] .jschema.i.validateAt[path,"[",string[i],"]"; items; el] }[path; items;;]'[til count obj; obj];
        ];
    ];

    :1b;
 };
