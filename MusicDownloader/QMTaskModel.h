//
//  QMTaskModel.h
//  fakeQQMusic
//
//  Created by user on 12-12-5.
//  Copyright (c) 2012年 crazyender. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "Header.h"

@interface QMTaskModel : NSObject<NSURLDownloadDelegate>
{
    NSURLDownload *_download;
    NSURLResponse *downloadResponse;
    unsigned bytesReceived;
    NSString *destFile;
}


@property (atomic, retain) NSString  *title;
@property (atomic, retain) NSString  *author;
@property (atomic, retain) NSString  *alumb;
@property (atomic, retain) NSString  *url;
@property (atomic)         NSUInteger size;
@property (atomic)         NSInteger progress;
@property (atomic)         NSUInteger TaskID;
@property (atomic)         BOOL     NotDownloading;
@property (atomic, retain) NSString  *ButtonTitle;
@property (atomic)         TopListType type;

// 以下为了取消下载后恢复到原来的列表
@property (atomic)         NSMutableArray *fromArray;
@property (atomic)         NSUInteger oldTaskID;

-(void)BeginDownload:(NSDictionary*)additionalHeader;
-(void)CancelDownload;
- (void)download:(NSURLDownload *)download decideDestinationWithSuggestedFilename:(NSString *)filename;
- (void)download:(NSURLDownload *)download didFailWithError:(NSError *)error;
- (void)downloadDidFinish:(NSURLDownload *)download;
- (void)download:(NSURLDownload *)download didReceiveResponse:(NSURLResponse *)response;
- (void)download:(NSURLDownload *)download didReceiveDataOfLength:(unsigned)length;
+(id)DeeperCopy:(QMTaskModel*)task fromArray:(NSMutableArray*)array;
-(void)test;

@end
