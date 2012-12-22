//
//  QMTabViewDelegate.m
//  MusicDownloader
//
//  Created by user on 12-12-9.
//  Copyright (c) 2012年 crazyender. All rights reserved.
//
#import <Cocoa/Cocoa.h>
#import "QMTabViewDelegate.h"
#import "QMService.h"

@implementation QMTabViewDelegate
+(id) initWithViewController:(NSArrayController*)controller andService:(QMService*)service withLock:(NSRecursiveLock*)lock
{
    QMTabViewDelegate *ret = [[super alloc]init];
    if (ret != nil) {
        ret.TaskModelArray = [ [NSMutableArray alloc] init];
        ret.ChineseTopArray = [ [NSMutableArray alloc] init];
        ret.EnglishTopArray = [ [NSMutableArray alloc] init];
        ret.JapaneseTopArray = [ [NSMutableArray alloc] init];
        ret.DancingArray = [ [NSMutableArray alloc] init];
        ret.ClassicMovieArray = [ [NSMutableArray alloc] init];
        ret.ClassicOldArray = [ [NSMutableArray alloc] init];
        ret.DownloadListArray = [ [NSMutableArray alloc] init];
        ret.HotOldArray = [ [NSMutableArray alloc] init];
        ret.NewTopArray = [ [NSMutableArray alloc] init];
        ret->_Controller = controller;
        ret->service = service;
        ret->tabLock = lock;
    }
    return ret;
}


-(NSMutableArray*)SelectedArray
{
    if (_Current == nil) {
        return self.TaskModelArray;
    }
    return _Current;
}


- (void)tabView:(NSTabView *)tabView didSelectTabViewItem:(NSTabViewItem *)tabViewItem
{
    [tabLock lock];
    
    NSString* tabID = [tabViewItem identifier];
    //NSLog( [NSString stringWithFormat:@"didSelectTabViewItem %@", tabID] );
    _Current  = [self ArrayBindToType:[tabID intValue]];
    self.SelectedType = [tabID intValue];
    if( [tabID intValue] != TopListDownload){
        [_Current removeAllObjects];
    }
    [self->_Controller setContent:self.SelectedArray];
    [tabLock unlock];
    [[NSNotificationCenter defaultCenter] postNotificationName:QMTabViewChanged object:tabID];
    
}

-(NSMutableArray*)ArrayBindToType:(TopListType)type
{
    NSMutableArray* ret = self.TaskModelArray;
    switch (type) {
        case 0:
            ret = self.TaskModelArray;
            break;
        case 1:
            ret = self.NewTopArray;
            break;
        case 2:
            ret = self.ChineseTopArray;
            break;
        case 3:
            ret = self.EnglishTopArray;
            break;
        case 4:
            ret = self.JapaneseTopArray;
            break;
        case 5:
            ret = self.ClassicOldArray;
            break;
        case 6:
            ret = self.ClassicMovieArray;
            break;
        case 7:
            ret = self.DancingArray;
            break;
        case 8:
            ret = self.HotOldArray;
            break;
        case 9:
            ret = self.DownloadListArray;
            break;
            
        default:
            ret = self.TaskModelArray;
            break;
    }
    return ret;
}

- (void)tabView:(NSTabView *)tabView willSelectTabViewItem:(NSTabViewItem *)tabViewItem
{
    [_Controller setContent:nil];
}


@end
