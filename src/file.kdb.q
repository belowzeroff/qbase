// Manipulation for On-Disk Files
// Copyright (c) 2021 - 2022 Jaskirat Rajasansir
// Copyright (c) 2026 Evgen Bielozorov
// Licensed under the Apache License, Version 2.0


// All kdb+ files have a 'magic number' as the first 2 bytes of the file:
//  - 0xff01 - atom or non-enumerated symbol list
//  - 0xfe20 - single-typed list
//  - 0xfd20 - enumerated symbol lists, complex lists or "new-format" lists
//
// The 'magic' number determines where the type and element length information resides. "New-format" list headers start at byte 4080 (4096 - 16)
//
// It's assumed that 4096 bytes (4 KB) is the smallest block size on most storage devices, therefore we read the full 4096 bytes
// instead of reading 2 smaller chunks


/ Assume any type greater than 200h is a atom
.file.kdb.cfg.atomOrList:0xf0;

.file.kdb.cfg.headerLength:4096;

/ Attributes based on the type
.file.kdb.cfg.attributes:``s`u`p`g;

/ Bytes within the header that contain useful information to extrace, based on the 'magic number' of the file
/ NOTE: For the 0xfe20 magic, the 'length' entry below (header bytes 8-15) is NOT reliable on all kdb+ builds - on
/ this repo's reference build (kdb+ 4.1, 2025.07.09) those bytes are always zero regardless of the real element
/ count (confirmed with 'read1' against 3-, 300- and 70000-element long lists - the first 16 header bytes are
/ byte-for-byte identical). '.file.kdb.getLength' therefore does NOT use this 'length' entry for 0xfe20 - it
/ derives the count from the file size instead (see '.file.kdb.cfg.singleTypedListHeaderBytes' / 'typeByteWidth'
/ and 'getLength' below). The entry is left here as-is (it is still used to document the header layout and may be
/ accurate on other kdb+ builds) but should not be relied upon for length extraction
.file.kdb.cfg.bytes:`magic xkey flip `magic`type`attr`length!"*II*"$\:();
.file.kdb.cfg.bytes,:`magic`type`attr`length!(0xff01; 2; 3; 4 + til 4);
.file.kdb.cfg.bytes,:`magic`type`attr`length!(0xfe20; 2; 3; 8 + til 8);
.file.kdb.cfg.bytes,:`magic`type`attr`length!enlist[0xfd20],(4096 - 16) + (2; 3; 8 + til 8);

/ For the 0xfe20 ('single-typed list') magic, the on-disk header is a constant 16 bytes before the element data
/ starts - verified by comparing 'hcount' (file size) against the known element count across 3-, 300- and
/ 70000-element long ('j') lists and 3- and 300-element int ('i') lists: (fileSize - 16) always divides exactly by
/ the type's element byte width to give the real count, for every length and both types tried
.file.kdb.cfg.singleTypedListHeaderBytes:16;

/ Fixed element byte width by kdb+ type number, for the plain (non-symbol) list types that can appear under the
/ 0xfe20 magic. Used by '.file.kdb.getLength' to turn a 0xfe20 file's size into an element count
.file.kdb.cfg.typeByteWidth:(`short$1 2 4 5 6 7 8 9 10 12 13 14 15 16 17 18 19)!1 16 1 2 4 8 4 8 1 8 4 4 8 8 4 4 4;

/ The start byte for the sym enumeration target (e.g. 'sym')
.file.kdb.cfg.symEnumByteStart:()!`int$();
.file.kdb.cfg.symEnumByteStart[enlist 0xfd20]:16;

/ The maximum number of bytes to read for the sym enumeration target
.file.kdb.cfg.symEnumReadBytes:64;


/  @returns (Dict) kdb file information summary based on the other functions in this namespace
/ TODO: Optimise further to only do a single read of the header bytes
.file.kdb.getSummary:{[file]
    :`type`attribute`length!.file.kdb[`getType`getAttribute`getLength]@\:file;
 };

/ Optimised kdb+ file type function. Only requires reading the first 4096 bytes of the specified file to return the type
/ (instead of "type get")
/  @param file (FilePath) The file to return the type for
/  @returns (Short) The file type
/  @see .file.kdb.cfg.atomOrList
.file.kdb.getType:{[file]
    header:read1 (file; 0; .file.kdb.cfg.headerLength);

    fileType:header .file.kdb.cfg.bytes[header 0 1]`type;
    :`short$((::; -256h +) .file.kdb.cfg.atomOrList < fileType) fileType;
 };

/ Optimised kdb+ 'get attribute' function. Only requires reading the first 4096 of the specified file to return the attribute
/ (instead of "attr get")
/  @param file (FilePath) The file to return the type for
/  @returns (Symbol) The attribute applied on the current file, or null symbol if no attribute
.file.kdb.getAttribute:{[file]
    header:read1 (file; 0; .file.kdb.cfg.headerLength);

    :.file.kdb.cfg.attributes header .file.kdb.cfg.bytes[header 0 1]`attr;
 };

/ Optimised element length function. Only requires reading the first 4096 bytes of the specified file to return the length
/ (instead of "count get").
/ NOTE: Optimised code path works for all atom and list types
/ NOTE: For the 0xfe20 ('single-typed list') magic, the element count is NOT read from the header - on this repo's
/ reference kdb+ build (4.1, 2025.07.09) that header 'length' field is always zero, so the count is instead derived
/ from the file size: (hcount file - 16) div (element byte width), which was verified against multiple list
/ lengths and element types (see '.file.kdb.cfg.singleTypedListHeaderBytes' / 'typeByteWidth' above)
/  @param file (FilePath) The file to return the element size
/  @returns (Long) The list length
.file.kdb.getLength:{[file]
    header:read1 (file; 0; .file.kdb.cfg.headerLength);

    magic:header 0 1;

    if[0xfe20 ~ magic;
        fileType:`short$header .file.kdb.cfg.bytes[magic]`type;
        :`long$((hcount file) - .file.kdb.cfg.singleTypedListHeaderBytes) div .file.kdb.cfg.typeByteWidth fileType;
    ];

    lengthBytes:0x0 sv reverse header .file.kdb.cfg.bytes[magic]`length;

    if[not 0xff01 ~ magic;
        :lengthBytes;
    ];

    fileType:header .file.kdb.cfg.bytes[magic]`type;

    $[.file.kdb.cfg.atomOrList < fileType;
        :1;
    (11h = fileType) & 0 < lengthBytes;
        :`long$lengthBytes;
    / else
        :count get file
    ];
 };

/ Optimised retrieval of the enumeration target for symbols
/ NOTE: Currently causes 2 4KB reads of the file header to get the file type (via .file.kdb.getType) and then to extract the symbol enumeration target
/  @param file (FilePath) The file to return the enumeration target
/  @returns (Symbol) The enumeration target file or null symbol if the file is a symbol file with no enumeration
/  @throws FileIsNotAnEnumerationException If the supplied file path target is not a symbol list or enumerated symbol list
.file.kdb.getSymEnumerationTarget:{[file]
    fileType:.file.kdb.getType file;

    $[11h = fileType;
        :`;
    not fileType within 20 76h;
        '"FileIsNotAnEnumerationException"
    ];

    header:read1 (file; 0; .file.kdb.cfg.headerLength);

    enumTgtBytes:header .file.kdb.cfg.symEnumByteStart[header 0 1] + til .file.kdb.cfg.symEnumReadBytes;
    enumTgtBytes:enumTgtBytes except 0x00;
    :`$`char$enumTgtBytes;
 };
