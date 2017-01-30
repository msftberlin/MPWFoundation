//
//  MPWExternalFilter.m
//  MPWFoundation
//
//  Created by Marcel Weiher on 1/29/17.
//
//

#import "MPWExternalFilter.h"

@interface MPWExternalFilter ()

@property (nonatomic, assign) int fdout,fdin,pid;


@end


@implementation MPWExternalFilter

+(instancetype)filterWithCommandString:(NSString *)command
{
    return [[[self alloc] initWithCommandString:command] autorelease];
}

-(BOOL)runCommand:(NSString *)theCommand
{
    const char *s=[theCommand fileSystemRepresentation];
    BOOL success=NO;
    int pipeFDsOut[2];
    int pipeFDsIn[2];
    pipe( pipeFDsOut);
    pipe( pipeFDsIn);
    
    self.fdout=pipeFDsOut[1];
    self.fdin=pipeFDsIn[0];
    switch (self.pid=fork())
    {
        case -1:
            break;
        case 0:
            fprintf(stderr,"child process with %s\n",s);
            dup2( pipeFDsOut[0], 0);       //  pipe to stdin (of child process)
            dup2( pipeFDsIn[1], 1);       //  pipe from stdout (of child process)
            close( pipeFDsIn[1]);
            close( pipeFDsOut[0]);
            close( pipeFDsIn[0]);
            close( pipeFDsOut[1]);
            system( s);
            fprintf(stderr,"did execute %s\n",s);
            exit(0);
        default:
            success=YES;
            break;
    }
    NSLog(@"pid: %d",self.pid);
    close(pipeFDsOut[0] );
    close(pipeFDsIn[1] );
    return success;
}

-(instancetype)initWithCommandString:(NSString *)command
{
    self=[super initWithTarget:[self defaultTarget]];
    ;
    if ( [self runCommand:command] ) {
        [NSThread detachNewThreadWithBlock:^{
            [self readFromStreamAndWriteToTarget];
        }];
    } else {
        self=nil;
    }
    return self;
}



-(void)writeObject:(id)anObject sender:aSender
{
    NSLog(@"will write: %@",anObject);
    @autoreleasepool {
        NSData *dataToWrite=[anObject asData];
        int written=write( self.fdout, [dataToWrite bytes], [dataToWrite length] );
    }
    NSLog(@"did write: %@",anObject);
}


-(void)readFromStreamAndWriteToTarget
{
    char buffer[8200];
    int actual=0;
    NSLog(@"read loop");
    while ( (actual=read(self.fdin, buffer, 8192)) > 0 ) {
        NSLog(@"did read %d bytes",actual);
        @autoreleasepool {
            NSData *dataToWrite=[NSData dataWithBytes:buffer length:strlen(buffer)];
            [target writeObject:dataToWrite sender:self];

        }
    }
    NSLog(@"done: read loop");
}

-(void)closeLocal
{
    NSLog(@"will close");
    close(self.fdout);
    int stat_loc=0;
    waitpid( self.pid,&stat_loc, 0 );
    NSLog(@"did waitpid()");
}

-(void)dealloc
{
    [self closeLocal];
    [super dealloc];
}

-(id)defaultTarget
{
    return [MPWByteStream streamWithTarget:[NSMutableString string]];
}

@end


@implementation MPWExternalFilter(testimng)

+(void)testUpcaseViaUnixTR
{
    MPWExternalFilter *filter=[self filterWithCommandString:@"tr '[a-z]' '[A-Z]'"];
    [filter writeObject:@"hello world!"];
    [filter close];
    IDEXPECT( [[filter target] target], @"HELLO WORLD!",@"upcase");
    
}


+testSelectors
{
    return @[
             @"testUpcaseViaUnixTR",
             ];
    
}

@end
