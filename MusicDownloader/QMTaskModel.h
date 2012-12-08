//
//  QMTaskModel.h
//  fakeQQMusic
//
//  Created by user on 12-12-5.
//  Copyright (c) 2012年 crazyender. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface QMTaskModel : NSObject<NSURLDownloadDelegate>
{
    NSURLDownload *_download;
    NSURLResponse *downloadResponse;
    unsigned bytesReceived;
    
}


@property (atomic, retain) NSString  *title;
@property (atomic, retain) NSString  *author;
@property (atomic, retain) NSString  *alumb;
@property (atomic, retain) NSString  *url;
@property (atomic)         NSUInteger size;
@property (atomic)         NSInteger progress;
@property (atomic)         NSUInteger TaskID;
@property (atomic)         BOOL     NotDownloading;

-(void)BeginDownload:(NSDictionary*)additionalHeader;
- (void)download:(NSURLDownload *)download decideDestinationWithSuggestedFilename:(NSString *)filename;
- (void)download:(NSURLDownload *)download didFailWithError:(NSError *)error;
- (void)downloadDidFinish:(NSURLDownload *)download;
- (void)download:(NSURLDownload *)download didReceiveResponse:(NSURLResponse *)response;
- (void)download:(NSURLDownload *)download didReceiveDataOfLength:(unsigned)length;
+(id)DeeperCopy:(QMTaskModel*)task;
-(void)test;

@end
