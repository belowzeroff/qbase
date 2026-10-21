// qbase Tests - s3 (presigned URL S3 client)
// Copyright (c) 2026 Evgen Bielozorov
// Licensed under the Apache License, Version 2.0

.require.lib`s3;


/ A realistic S3 error XML body, with surrounding/irrelevant tags, to prove extraction targets
/ the specific '<Code>' / '<Message>' tags rather than matching the whole string
.t.i.s3_errorXml:"<?xml version=\"1.0\" encoding=\"UTF-8\"?><Error><Code>AccessDenied</Code><Message>Access Denied</Message><RequestId>7F283-REQID</RequestId></Error>";


.t.s3_parseErrorXml_extractsCodeAndMessage:{[]
    parsed:.s3.i.parseErrorXml .t.i.s3_errorXml;

    .test.assert.equals[`AccessDenied; parsed`code];
    .test.assert.equals["Access Denied"; parsed`message];
 };

.t.s3_parseErrorXml_nonXmlBodyFallsBackToUnknownError:{[]
    parsed:.s3.i.parseErrorXml "Internal Server Error";

    .test.assert.equals[`UnknownError; parsed`code];
    .test.assert.equals["Internal Server Error"; parsed`message];
 };

.t.s3_parseErrorXml_emptyBodyFallsBackToUnknownError:{[]
    parsed:.s3.i.parseErrorXml "";

    .test.assert.equals[`UnknownError; parsed`code];
    .test.assert.equals[""; parsed`message];
 };

.t.s3_raiseIfError_successStatusDoesNotRaise:{[]
    response:`statusCode`statusType`statusDetail`headers`body!(200i; `success; "OK"; ()!(); "");

    .test.assert.equals[(::); .s3.i.raiseIfError response];
 };

.t.s3_raiseIfError_clientErrorRaisesWithParsedCode:{[]
    response:`statusCode`statusType`statusDetail`headers`body!(403i; `clientError; "Forbidden"; ()!(); .t.i.s3_errorXml);

    .test.assert.raisesLike[.s3.i.raiseIfError; enlist response; "*AccessDenied*"];
 };

.t.s3_getObject_nonStringUrlRaisesWithoutNetworkCall:{[]
    .test.assert.raisesLike[.s3.getObject; enlist 123; "IllegalArgumentException*"];
 };

.t.s3_putObject_nonStringUrlRaisesWithoutNetworkCall:{[]
    .test.assert.raisesLike[.s3.putObject; (123; "body"; ""); "IllegalArgumentException*"];
 };

.t.s3_putObject_nonStringBodyRaisesWithoutNetworkCall:{[]
    .test.assert.raisesLike[.s3.putObject; ("http://presigned.example/obj"; 123; ""); "IllegalArgumentException*"];
 };

.t.s3_deleteObject_nonStringUrlRaisesWithoutNetworkCall:{[]
    .test.assert.raisesLike[.s3.deleteObject; enlist 123; "IllegalArgumentException*"];
 };
