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

@implementation QMAppDelegate


- (void)applicationDidFinishLaunching:(NSNotification *)aNotification
{

    self.TaskModelArray = [ [NSMutableArray alloc] init];
    [self.arrayController setContent:self.TaskModelArray];
    service = [[QMSosoService alloc]init];
}


-(void)insertObject:(TaskModel *)p inTaskModelArrayAtIndex:(NSUInteger)index
{
    [_TaskModelArray insertObject:p atIndex:index];
}

-(void)removeObjectFromTaskModelArrayAtIndex:(NSUInteger)index
{
    [_TaskModelArray removeObjectAtIndex:index];
}

-(void)setTaskModelArray:(NSMutableArray *)a
{
    _TaskModelArray = a;
}

-(NSMutableArray*)TaskModelArray
{
    return _TaskModelArray;
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

    [self.arrayController removeObjects:_TaskModelArray];
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
    QMTaskModel* current = [self.TaskModelArray objectAtIndex:index];
    if (current != nil) {
        [service BeginDownload:current];
    } else {
        [NSException raise:@"Unexpected" format:@"fatal error"];
    }
}

@end
