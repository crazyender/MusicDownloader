//
//  QMSosoService.m
//  fakeQQMusic
//
//  Created by user on 12-12-6.
//  Copyright (c) 2012年 crazyender. All rights reserved.
//

#import "QMService.h"
#import "QMSosoSearchOperation.h"
#import "QMTaskModel.h"

@implementation QMService

-(id)init
{
    self = [super init];
    searchOperationQueue = [[NSOperationQueue alloc]init];
    // can search all kind of content at the same time
    [searchOperationQueue setMaxConcurrentOperationCount:10];
    
    downloadOperationQueue = [[NSOperationQueue alloc]init];
    // FIXME: should configurable
    [downloadOperationQueue setMaxConcurrentOperationCount:5];
    return self;
}

-(void)SearchMusicWithName:(NSString*)name Observer:(id)aObserver Selector:(SEL)aSelector
{
    QMSosoSearchOperation *operation = [[QMSosoSearchOperation alloc]initWithTypeAndName:TopListSearch AndName:name];
    [self->searchOperationQueue addOperation:operation];
}

-(void)GetTopListWithType:(TopListType)type Observer:(id)aObserver Selector:(SEL)aSelector
{
    QMSosoSearchOperation *operation = [[QMSosoSearchOperation alloc]initWithTypeAndName:type AndName:nil];
    [self->searchOperationQueue addOperation:operation];
}



-(void)BeginDownload:(QMTaskModel*)model
{
    NSDictionary *additionalHeaders = nil;
    NSRange location = [model.url rangeOfString:@"qqmusic.qq.com"];
    if (location.length == 0) {
        additionalHeaders = nil;
    }else{
        additionalHeaders = [NSDictionary dictionaryWithObjectsAndKeys:
                @"http://soso.music.qq.com/fcgi-bin/fcg_song.fcg", @"Referer",
                @"*/*", @"Accept",
                @"1", @"DNT",
                @"Mozilla/5.0 (compatible; MSIE 9.0; Windows NT 6.1; WOW64; Trident/5.0; MALC)", @"User-Agent",
                @"qqmusic_fromtag=10; qqmusic_sosokey=4D96476733A6D833E90FEA9E590408D171B92452775E15FB", @"Cookie",
                nil];
    }
    [model BeginDownload:additionalHeaders];
    
}


@end
