//
//  MPWDelimitedTable.m
//  MPWFoundation
//
//  Created by Marcel Weiher on 9/22/13.
//
//

#import "MPWDelimitedTable.h"
#import "NSBundleConveniences.h"

@implementation MPWDelimitedTable

objectAccessor(NSData, data, setData)
lazyAccessor(NSArray, headerKeys, setHeaderKeys, computeHeaderKeys)
objectAccessor(NSString, fieldDelimiter, setFieldDelimiter)
lazyAccessor(MPWIntArray, lineOffsets, setLineOffsets, computeLineOffsets)
intAccessor(eolLength, setEOLLength)

-(NSString*)lineDelimiter
{
    return @"\r\n";
}

-(MPWIntArray*)computeLineOffsets
{
    unsigned const char *bytes=[[self data] bytes];
    unsigned const char *cur=bytes;
    unsigned const char *end=cur+[[self data] length];
    MPWIntArray *offsets=[MPWIntArray array];
    [offsets addInteger:0];
    if ( bytes) {
        while ( cur < end ) {
            char last = *cur++;
            if ( last == '\r' || last=='\n') {
                if ( last == '\r' && *cur=='\n') {
                    cur++;
                    [self setEOLLength:2];
                } else {
                    [self setEOLLength:1];
                }
                if ( cur < end) {
                    [offsets addInteger:cur-bytes];
                }
            }
        }
        [offsets addInteger:end-bytes];
    }
    return offsets;
}

-initWithData:(NSData*)newTableData delimiter:(NSString*)newFieldDelimiter
{
    self=[super init];
    [self setFieldDelimiter:newFieldDelimiter];
    [self setData:newTableData];
    return self;
}

-initWithTabSeparatedData:(NSData*)newTableData
{
    return [self initWithData:newTableData delimiter:@"\011"];
}

-initWithCommaSeparatedData:(NSData*)newTableData
{
    return [self initWithData:newTableData delimiter:@","];
}

-(void)dealloc
{
    RELEASE(lineOffsets);
    RELEASE(fieldDelimiter);
    RELEASE(headerKeys);
    [super dealloc];
}

-(int)totalLineCount
{
    return [[self lineOffsets] count]-1;
}

-(int)count
{
    return [self totalLineCount]-1;
}

-(NSString*)lineAtIndex:(int)anIndex
{
    unsigned const char *bytes=[[self data] bytes];
    int offset=[[self lineOffsets] integerAtIndex:anIndex];
    int nextOffset=[[self lineOffsets] integerAtIndex:anIndex+1];
    int len = nextOffset-offset-[self eolLength];
    return [[[NSString alloc] initWithBytes:bytes+offset length:len encoding:NSASCIIStringEncoding] autorelease];
}

-(NSString*)headerLine
{
    return [self lineAtIndex:0];
}

-(NSArray*)computeHeaderKeys
{
    return [[self headerLine] componentsSeparatedByString:[self fieldDelimiter]];
}

-(NSArray*)dataAtIndex:(int)anIndex
{
    return [[self lineAtIndex:anIndex+1] componentsSeparatedByString:[self fieldDelimiter]];
}

-(NSDictionary*)dictionaryAtIndex:(int)anIndex
{
    return [NSDictionary
            
            dictionaryWithObjects:[self dataAtIndex:anIndex]
                                       forKeys:[self headerKeys]];
}

@end

#import "DebugMacros.h"

@implementation MPWDelimitedTable(testing)



+_testTable
{
    NSData *tableData=[self resourceWithName:@"first4" type:@"tabdelim"];
    MPWDelimitedTable *table=[[[self alloc] initWithTabSeparatedData:tableData] autorelease];
    return table;
}

+_testCSVTable
{
    NSData *tableData=[self resourceWithName:@"archiving-times-and-sizes" type:@"csv"];
    MPWDelimitedTable *table=[[[self alloc] initWithCommaSeparatedData:tableData] autorelease];
    return table;
}

+(void)testGetNumberOfLines
{
    MPWDelimitedTable *table=[self _testTable];
    INTEXPECT([table totalLineCount], 4, @"total lines");
    INTEXPECT([table count], 3, @"data lines");
}

+(void)testHeaderKeys
{
    NSArray *expectedKeys=@[
                            @"VD",
                            @"ID",
                            @"BF",
                            @"LK",
                            @"OK",
                            @"RN",
                            @"RZ",
                            @"ZT",
                            @"NS",
                            @"VY",
                            @"TN",
                            @"TA",
                            @"NA",
                            @"VN",
                            @"TI",
                            @"VW",
                            @"NZ",
                            @"SZ",
                            @"BG",
                            @"VB2",
                            @"NA2",
                            @"VN2",
                            @"TI2",
                            @"VW2",
                            @"HZ2",
                            @"SZ2",
                            @"BG2",
                            @"VB3",
                            @"NA3",
                            @"VN3",
                            @"TI3",
                            @"VW3",
                            @"HZ3",
                            @"SZ3",
                            @"BG3",
                            @"GN",
                            @"GTN",
                            @"GD",
                            @"ST",
                            @"HN",
                            @"HZ",
                            @"PLZ",
                            @"PO",
                            @"GV",
                            @"GB",
                            @"PKZ",
                            @"DMU",
                            @"LKMU",
                            @"OKMU",
                            @"RNMU",
                            @"ZTMU",
                            @"VDMU",
                            @"LZMU",
                            @"OKRU",
                            @"RNRU",
                            @"VYRU",
                            @"ZTRU",
                            @"NSRU",
                            @"NUAK",
                            @"NUPM",
                            @"NUEM",
                            @"RUVO",
                            @"VYVO",
                            @"RUAZ",
                            @"SEGD",
                            @"SN",
                            @"NX",
                            @"BGA",
                            @"F1",
                            @"F2",
                            @"F3",
                            @"F4",
                            @"F5",
                            @"BN",
                            @"BA",
                            @"HS",
                            @"LI",
                            @"IV",
                            @"VI",
                            @"NI",
                            @"NETZ",
                            @"AA1",
                            @"AA2",
                            @"AA3",
                            @"EX",
                            @"VX",
                            @"SX",
                            @"FD",
                            @"DW",
                            @"ETV1",
                            @"ETV2",
                            @"ETN1",
                            @"ETN2",
                            @"ZA",
                            @"ASA",
                            @"STT",
                            @"KT",
                            @"KC",
                            @"PG",
                            @"OD",
                            @"GDK",
                            @"LN",
                            @"KZB",
                            @"X_WGS84",
                            @"Y_WGS84",
                            @"X_LCC",
                            @"Y_LCC",
                            @"STADTTEIL",
                            @"QKZ",
                            @"LIEFERGRUND",
                            @"WIDERGEO",
                            @"SO",
                            @"SOA",
                            @"SOB",
                            @"HEUNTER",
                            @"ANZNRNEU",
                            @"ANZHOEHE",
                            @"ANZBREITE",
                            @"GEBIET",
                            @"GRAFIK",
                            @"ZBA",
                            @"ANKDNR",
                            @"ANARTA",
                            @"ANZNRALT",
                            @"BAAP_ID",
                            @"BVSE_ID",
                            @"PROKOM_ID",
                            @"PROKOM_LI",
                            @"PROKOM_VI",
                            @"PROKOM_NI",
                            @"PROKOM_IV",
                            @"PROKOM_POSITION",
                            @"PROKOM_MASTER_ID" ];

    MPWDelimitedTable *table=[self _testTable];
    NSArray *keys=[table headerKeys];
    INTEXPECT([keys count], 133, @"number of keys");
    IDEXPECT(keys, expectedKeys, @"keys");
}

+(void)testDictionary
{
    MPWDelimitedTable *table=[self _testTable];
    NSDictionary *dict=[table dictionaryAtIndex:2];
    IDEXPECT([dict objectForKey:@"ID"], @"213596507", @"ID");
    IDEXPECT([dict objectForKey:@"NA"], @"Ehinger-Schwarz GmbH & Co KG", @"NA");
}

+(void)testCSVTable
{
    MPWDelimitedTable *table=[self _testCSVTable];
    INTEXPECT([table totalLineCount], 18, @"total lines");
    INTEXPECT([table count], 17, @"data lines");
    NSArray *keys=[table headerKeys];
    NSArray *expectedKeys=@[     @"",
                                 @"serialize",
                                 @"deserialize",
                                 @"size (MB)",
                                 @"compressed size (MB)",
                                 @"raw peak memory (MB)",
                                 @"peak overhead  (MB)",
                                 @"% time",
                                 @"% space",
                                 @"deserialize - object creation",
                                 ];
    

    
    IDEXPECT(keys, expectedKeys, @"header keys");
    NSDictionary *dict=[table dictionaryAtIndex:2];
    IDEXPECT([dict objectForKey:@""], @"JSON", @"label");
    IDEXPECT([dict objectForKey:@"serialize"], @"2.39", @"time");
}

+testSelectors
{
    return @[
             @"testGetNumberOfLines",
             @"testHeaderKeys",
             @"testDictionary",
             @"testCSVTable",
             ];
}

@end