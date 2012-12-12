//
//  QMSosoService.h
//  fakeQQMusic
//
//  Created by user on 12-12-6.
//  Copyright (c) 2012年 crazyender. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "Header.h"
@class QMTaskModel;


@interface QMService : NSObject
{
    NSOperationQueue *searchOperationQueue;
    NSOperationQueue *downloadOperationQueue;
    
}

-(void)SearchMusicWithName:(NSString*)name Observer:(id)aObserver Selector:(SEL)aSelector;
-(void)GetTopListWithType:(TopListType)type Observer:(id)aObserver Selector:(SEL)aSelector;;
-(void)BeginDownload:(QMTaskModel*)model;


@end
