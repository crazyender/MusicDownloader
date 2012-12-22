//
//  QMMusicManager.h
//  MusicDownloader
//
//  Created by user on 12-12-22.
//  Copyright (c) 2012年 crazyender. All rights reserved.
//

#import <Foundation/Foundation.h>
@class QMTaskModel;
@interface QMMusicManager : NSObject
{

}

+(id)GetInstance;

-(BOOL)IsRecordExist:(NSString*)url;
-(BOOL)DeleteRecord:(NSString*)url;
-(BOOL)InsertRecord:(QMTaskModel*)item MatchLocal:(NSString*) Local;
-(BOOL)UpdateRecord:(QMTaskModel*)item WithLocal:(NSString*)local;
-(NSMutableArray*)GetAllItem;
-(void)RemoveNotExistRecord;
-(void)close;

@end
