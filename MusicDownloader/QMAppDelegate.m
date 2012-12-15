//
//  QMAppDelegate.m
//  fakeQQMusic
//
//  Created by user on 12-11-29.
//  Copyright (c) 2012年 crazyender. All rights reserved.
//
#import <Cocoa/Cocoa.h>
#import "QMAppDelegate.h"
#import "QMTaskModel.h"
#import "QMService.h"
#import "QMTabViewDelegate.h"

@implementation QMAppDelegate

-(NSMutableArray*)getDataCollectionFromTabIdentifier:(NSString*)tabID
{
    return nil;
}

- (void)applicationDidFinishLaunching:(NSNotification *)aNotification
{
    tabLock = [[NSRecursiveLock alloc]init];
    service = [[QMService alloc]init];
    tabViewDelegate = [QMTabViewDelegate initWithViewController:self.arrayController andService:service withLock:tabLock];
    [self.tabView setDelegate:tabViewDelegate];
    
    NSView *view = [[self.tabView tabViewItemAtIndex:0]view];
    unsigned long count = [[self.tabView tabViewItems]count];
    for( unsigned long index = 1; index < count; index++ )
    {
        NSTabViewItem *item = [self.tabView tabViewItemAtIndex:index];
        [item setView:view];
    }
    
    [self.tabView selectTabViewItemWithIdentifier:@"0"];
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(OnTaskItemAdded:)
                                                 name:QMItemFetched
                                               object:nil];
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(OnTabViewChanged:)
                                                 name:QMTabViewChanged
                                               object:nil];
    
}

- (void)applicationWillTerminate:(NSNotification *)aNotification
{
    if (tabViewDelegate != nil && tabViewDelegate.DownloadListArray != nil){
        
        for( QMTaskModel* item in tabViewDelegate.DownloadListArray ){
            if (item.NotDownloading == NO) {
                [item CancelDownload];
            }
        
        }
    }
}


-(void)insertObject:(TaskModel *)p inTaskModelArrayAtIndex:(NSUInteger)index
{
    [[tabViewDelegate SelectedArray] insertObject:p atIndex:index];
}

-(void)removeObjectFromTaskModelArrayAtIndex:(NSUInteger)index
{
    [[tabViewDelegate SelectedArray] removeObjectAtIndex:index];
}

-(NSMutableArray*)TaskModelArray
{
    return [tabViewDelegate SelectedArray];
}




/* format like this:
 QMTaskModel * model = [[QMTaskModel alloc] init];
 model.title = @"hello.mp3";
 model.url = @"http://example.com/hello.mp3";
 model.author = @"周杰伦";
 model.alumb = @"七月的肖邦";
 model.size = 45;
 model.TaskID = [self.TaskModelArray count];
 model.progress = 0;
 [self.arrayController addObject:model];
 */

- (IBAction)SearchButtonPressed:(NSButton*)sender
{
    [self.tabView selectTabViewItemWithIdentifier:@"0"];
    [self.arrayController removeObjects:[tabViewDelegate SelectedArray]];
    NSString *name = [self.textName stringValue];
    [service SearchMusicWithName:name Observer:self Selector:@selector(OnTaskItemAdded:)];

}

- (IBAction)DownloadButtonPressed:(NSButton*)sender
{
    
    NSUInteger index = [[sender toolTip] intValue];
    
    QMTaskModel* current = nil;
    NSMutableArray* selected = [tabViewDelegate SelectedArray];
    for( QMTaskModel * item in selected)
    {
        if (item.TaskID == index) {
            current = item;
            break;
        }
    }
    if (current == nil) {
        NSLog( [NSString stringWithFormat:@"can not found task with id %ld", (long)index] );
        return;
    }
    
    if (current != nil) {
        NSString *buttonTitle = current.ButtonTitle;
        if ([buttonTitle isEqualToString:@"取消"]) {
            // 取消下载
            [current CancelDownload];
            // 在下载列表里删除
            [self.arrayController removeObject:current];
            
        }else{
            // add to download list
            QMTaskModel *item = [QMTaskModel DeeperCopy:current fromArray:selected];
            item.TaskID = [tabViewDelegate.DownloadListArray count];
            [tabViewDelegate.DownloadListArray addObject:item];
        
            // then remove from current
            [self.arrayController removeObject:current];
        
            [service BeginDownload:item];
        }
    } else {
        [NSException raise:@"Unexpected" format:@"fatal error"];
    }
}



-(void)OnTabViewChanged:(NSNotification*)noti
{
    NSString* tabID = noti.object;

    TopListType type = (TopListType)[tabID intValue];
        if( type != TopListDownload && type != TopListSearch )
    {
        [self->service GetTopListWithType:type Observer:self Selector:@selector(OnTaskItemAdded:)];
        
    }
    else if( type == TopListSearch )
    {
        NSString *name = [self.textName stringValue];
        [service SearchMusicWithName:name Observer:self Selector:@selector(OnTaskItemAdded:)];
    }
}

-(void)AddItemToUIWithMainThread:(QMTaskModel*) item
{
    [self->tabLock lock];
    TopListType type = self->tabViewDelegate.SelectedType;
    if (type == item.type ){
        [self.arrayController addObject:item];
    }else{
        [[self->tabViewDelegate ArrayBindToType:item.type]addObject:item];
    }
    [self->tabLock unlock];
    
    
    
}

-(void)OnTaskItemAdded:(NSNotification*)noti
{
    [self->tabLock lock];
    QMTaskModel* item = noti.object;
    
    TopListType type = self->tabViewDelegate.SelectedType;
    NSMutableArray* downloadArray = tabViewDelegate.DownloadListArray;
    NSMutableArray* current = [tabViewDelegate ArrayBindToType:type];
    
    if( current != downloadArray ){
        for (QMTaskModel* tmp in downloadArray) {
            if ([tmp.url isEqualToString:item.url]) {
                [self->tabLock unlock];
                return;
            }
        }
    }
    //NSLog([NSString stringWithFormat:@"[test] OnTaskItemAdded [%@]with type %d to %d selected %d" ,item.title, item.type, type, tabViewDelegate.SelectedType]);
    
    [self performSelectorOnMainThread:@selector(AddItemToUIWithMainThread:) withObject:item waitUntilDone:NO];

    
    [self->tabLock unlock];
    
}


@end
