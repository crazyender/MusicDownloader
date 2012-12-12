//
//  QMSearchOperation.h
//  MusicDownloader
//
//  Created by user on 12-12-12.
//  Copyright (c) 2012年 crazyender. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "Header.h"

@interface QMSosoSearchOperation : NSOperation
{
    NSString *searchName;
    TopListType searchType;
    BOOL started;
    
}

-(id)initWithTypeAndName:(TopListType)type AndName:(NSString*)name;
-(void)main;
- (BOOL)isExecuting;

@end
