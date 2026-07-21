// qbase Tests - jschema (JSON schema validation)
// Copyright (c) 2026 Evgen Bielozorov
// Licensed under the Apache License, Version 2.0

.require.lib`jschema;


.t.jschema_validObjectPasses:{[]
    str:enlist[`type]!enlist`string;
    num:enlist[`type]!enlist`number;
    schema:`type`required`fields!(`dict; `name`age; `name`age!(str; num));
    .test.assert.true[.jschema.validate[schema; `name`age!("Alice"; 30f)]];
 };

.t.jschema_missingRequiredKeyFails:{[]
    schema:`type`required!(`dict; `name`age);
    .test.assert.false[.jschema.isValid[schema; enlist[`name]!enlist "Bob"]];
 };

.t.jschema_wrongTypeRaises:{[]
    num:enlist[`type]!enlist`number;
    schema:`type`fields!(`dict; enlist[`age]!enlist num);
    obj:enlist[`age]!enlist "notanumber";
    .test.assert.raisesLike[.jschema.validate[schema;]; enlist obj; "*SchemaValidation*"];
 };

.t.jschema_listItemsValidated:{[]
    num:enlist[`type]!enlist`number;
    schema:`type`items!(`list; num);
    .test.assert.true[.jschema.validate[schema; 1 2 3f]];
    .test.assert.false[.jschema.isValid[schema; (1f; "two"; 3f)]];
 };

.t.jschema_unknownTypeRaises:{[]
    schema:enlist[`type]!enlist`bogustype;
    .test.assert.raisesLike[.jschema.validate[schema;]; enlist 5f; "*unknown schema type*"];
 };
