//
//  QMSosoService.h
//  fakeQQMusic
//
//  Created by user on 12-12-6.
//  Copyright (c) 2012年 crazyender. All rights reserved.
//

#import <Foundation/Foundation.h>

@class QMTaskModel;

@interface QMSosoService : NSObject
{
    NSMutableData  *receivedData;
    NSURLConnection *connection;
    
}

-(NSMutableArray*)SearchMusicWithName:(NSString*)name asWellAsAuthor:(NSString*)author;
-(void)BeginDownload:(QMTaskModel*)model;


@end
