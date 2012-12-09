//
//  QMAppDelegate.m
//  fakeQQMusic
//
//  Created by user on 12-11-29.
//  Copyright (c) 2012年 crazyender. All rights reserved.
//

#import "QMAppDelegate.h"
#import "QMTaskModel.h"
#import "QMSosoService.h"
#import "QMTabViewDelegate.h"

@implementation QMAppDelegate

-(NSMutableArray*)getDataCollectionFromTabIdentifier:(NSString*)tabID
{
    return nil;
}

- (void)applicationDidFinishLaunching:(NSNotification *)aNotification
{

    tabViewDelegate = [QMTabViewDelegate initWithViewController:self.arrayController];
    [self.tabView setDelegate:tabViewDelegate];
    
    NSView *view = [[self.tabView tabViewItemAtIndex:0]view];
    unsigned long count = [[self.tabView tabViewItems]count];
    for( unsigned long index = 1; index < count; index++ )
    {
        NSTabViewItem *item = [self.tabView tabViewItemAtIndex:index];
        [item setView:view];
    }
    
    [self.tabView selectTabViewItemWithIdentifier:@"0"];
    //[self.arrayController setContent: [tabViewDelegate SelectedArray]];
    service = [[QMSosoService alloc]init];
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
    NSString *author = [self.textAuthor stringValue];
    NSMutableArray *ret = [service SearchMusicWithName:name asWellAsAuthor:author];
    for (TaskModel * model in  ret){
        [self.arrayController addObject:model];
    }

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
            // 然后加回到原来的列表
            QMTaskModel *item = [QMTaskModel DeeperCopy:current fromArray:nil];
            item.TaskID = current.oldTaskID;
            item.ButtonTitle = @"下载";
            int insertIndex = 0;
            for (int index = 0; index < [current.fromArray count]; index++) {
                QMTaskModel *e = [current.fromArray objectAtIndex:index];
                if (e.TaskID > item.TaskID) {
                    insertIndex = index;
                    break;
                }
            }
            [current.fromArray insertObject:item atIndex:insertIndex];
            
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


@end
