//
//  MPWURLFetchStream.h
//  StackOverflow
//
//  Created by Marcel Weiher on 3/31/15.
//  Copyright (c) 2015 Marcel Weiher. All rights reserved.
//

#import <MPWFoundation/MPWFoundation.h>

@interface MPWURLFetchStream : MPWStream
{
    NSURL *baseURL;
    NSURLSession *downloader;
}

@property (nonatomic, strong) NSURL *baseURL;

+streamWithBaseURL:(NSURL*)newBaseURL target:aTarget;
-initWithBaseURL:(NSURL*)newBaseURL target:aTarget;


@end
