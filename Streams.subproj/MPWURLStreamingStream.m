//
//  MPWURLStreamingStream.m
//  MPWFoundation
//
//  Created by Marcel Weiher on 9/14/17.
//
//

#import "MPWURLStreamingStream.h"
#import "MPWByteStream.h"

@interface MPWURLStreamingFetchHelper : MPWStream <NSURLSessionDelegate>

@property (nonatomic, strong)  NSMutableSet *inflight;
@property (nonatomic, strong) NSThread *targetThread;

@end



@implementation MPWURLStreamingStream


-(instancetype)initWithBaseURL:(NSURL*)newBaseURL target:aTarget
{
    MPWURLStreamingFetchHelper *helper = [MPWURLStreamingFetchHelper streamWithTarget:aTarget];    
    NSURLSession *session=[NSURLSession sessionWithConfiguration:[self config]
                                                        delegate:helper
                                                   delegateQueue:nil];
    self.streamingDelegate=helper;
    self=[super initWithBaseURL:newBaseURL target:aTarget session:session];
    helper.targetThread = self.targetThread;
    self.streamingDelegate.inflight = self.inflight;
    return self;
}


- (NSURLSessionTask*)taskForExecutingRequest:(MPWURLRequest*)request
{
    NSParameterAssert( [request isStreaming]);
    return [[self downloader] dataTaskWithRequest: [self resolvedRequest:request]];
}

-(void)setTarget:(id)newVar
{
    [super setTarget:newVar];
    [self.streamingDelegate setTarget:newVar];
}


-(void)dealloc
{
    [_streamingDelegate release];
    [super dealloc];
}


@end


@implementation MPWURLStreamingFetchHelper

- (void)URLSession:(NSURLSession *)session dataTask:(NSURLSessionDataTask *)dataTask
    didReceiveData:(NSData *)data
{
    if (self.targetThread) {
        [target performSelector:@selector(writeObject:)
                        onThread:self.targetThread
                        withObject:data
                    waitUntilDone:NO];
    } else {
        [target writeObject:data];
    }    
}

- (void)URLSession:(NSURLSession *)session task:(NSURLSessionTask *)task
didCompleteWithError:(nullable NSError *)error
{
    @synchronized (self) {
        [self.inflight removeObject:task];
    }
    if ( error ){
        [self reportError:error];
    }
    [target close];
}

-(void)dealloc
{
    [_inflight release];
    [super dealloc];
}

@end

#import "DebugMacros.h"

@implementation MPWURLStreamingStream(testing)

+(void)testCanHandleDataStreamingResponse
{
    NSMutableString *testTarget=[NSMutableString string];
    NSURL *testURL=[[NSBundle bundleForClass:self] URLForResource:@"ResourceTest" withExtension:nil];
    MPWStream *target=[MPWByteStream streamWithTarget:testTarget];
    MPWURLStreamingStream* stream=[self streamWithTarget:target];
    [stream streamingGet:testURL body:nil];
    [stream awaitResultForSeconds:0.5];
    IDEXPECT( testTarget, @"This is a simple resource",@"should have written");
    
}


+testSelectors
{
    return
    @[
      @"testCanHandleDataStreamingResponse",
      ];
}

@end

