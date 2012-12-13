//
//  QMTaskModel.m
//  fakeQQMusic
//
//  Created by user on 12-12-5.
//  Copyright (c) 2012年 crazyender. All rights reserved.
//

#import "QMTaskModel.h"

@implementation QMTaskModel


-(void) BeginDownload:(NSDictionary*)additionalHeader
{
    NSMutableURLRequest *theRequest = [NSMutableURLRequest requestWithURL:[NSURL URLWithString:self.url]
                                                cachePolicy:NSURLRequestUseProtocolCachePolicy
                                            timeoutInterval:60.0];
    
    if (additionalHeader != nil) {
        [ additionalHeader enumerateKeysAndObjectsUsingBlock:^(id key, id obj, BOOL *stop) {
            [theRequest setValue:obj forHTTPHeaderField:key];
            *stop = NO;
        }];
    }
    

    
    destFile = @"";
    // Create the download with the request and start loading the data.
    NSURLDownload  *theDownload = [[NSURLDownload alloc] initWithRequest:theRequest delegate:self];
    if (!theDownload) {
        NSLog(@"can not create NSURLDownload instance");
    }
    _download = theDownload;
}

-(void)CancelDownload
{
    if (_download != nil) {
        [_download cancel];
        NSError *error;
        [[NSFileManager defaultManager] removeItemAtPath:destFile error:&error];
        self.ButtonTitle = @"下载";
        self.progress = 0;
        self.NotDownloading = YES;
    }
}

- (void)download:(NSURLDownload *)download decideDestinationWithSuggestedFilename:(NSString *)filename
{
    NSString *destinationFilename;
    NSString *homeDirectory = NSHomeDirectory();
    
    destinationFilename = [[homeDirectory stringByAppendingPathComponent:@"Music"]
                           stringByAppendingPathComponent:self.title];
    destFile = destinationFilename;
    [download setDestination:destinationFilename allowOverwrite:YES];
}


- (void)download:(NSURLDownload *)download didFailWithError:(NSError *)error
{
    // Release the download.
    _download = nil;
    NSError *err;
    [[NSFileManager defaultManager] removeItemAtPath:destFile error:&err];
    self.ButtonTitle = @"下载";
    self.progress = 0;
    self.NotDownloading = YES;
    
    // Inform the user.
    NSLog(@"Download failed! Error - %@ %@",
          [error localizedDescription],
          [[error userInfo] objectForKey:NSURLErrorFailingURLStringErrorKey]);
}

- (void)downloadDidFinish:(NSURLDownload *)download
{
    // Release the download.
    _download = nil;
    self.progress = 100;
    self.ButtonTitle = @"下载";
    self.NotDownloading = YES;
    
    // Do something with the data.
    NSLog(@"%@",@"downloadDidFinish");
}


- (void)download:(NSURLDownload *)download didReceiveResponse:(NSURLResponse *)response
{
    // Reset the progress, this might be called multiple times.
    // bytesReceived is an instance variable defined elsewhere.
    bytesReceived = 0;
    self.progress = 0;
    self.ButtonTitle = @"取消";
    self.NotDownloading = NO;
    
    // Retain the response to use later.
    downloadResponse = response;
}

- (void)download:(NSURLDownload *)download didReceiveDataOfLength:(unsigned)length
{
    long long expectedLength = [downloadResponse expectedContentLength];
    
    bytesReceived = bytesReceived + length;
    
    if (expectedLength != NSURLResponseUnknownLength) {
        // If the expected content length is
        // available, display percent complete.
        float percentComplete = (bytesReceived/(float)expectedLength)*100.0;
        self.progress = (int)percentComplete;
    } else {
        // If the expected content length is
        // unknown, just log the progress.
        NSLog(@"Bytes received - %d",bytesReceived);
    }
}

+(id)DeeperCopy:(QMTaskModel*)task fromArray:(NSMutableArray*)array
{
    QMTaskModel* ret = [[QMTaskModel alloc]init];
    ret.title = task.title;
    ret.author = task.author;
    ret.alumb = task.alumb;
    ret.url = task.url;
    ret.size = task.size;
    ret.progress = task.progress;
    ret.TaskID = task.TaskID;
    
    return ret;
}


-(void)test
{
    self.progress = 50;
}

@end
