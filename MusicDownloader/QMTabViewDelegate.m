//
//  QMTabViewDelegate.m
//  MusicDownloader
//
//  Created by user on 12-12-9.
//  Copyright (c) 2012年 crazyender. All rights reserved.
//

#import "QMTabViewDelegate.h"

@implementation QMTabViewDelegate
+(id) initWithViewController:(NSArrayController*)controller
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
    NSString* tabID = [tabViewItem identifier];
    switch ([tabID intValue]) {
        case 0:
            _Current = self.TaskModelArray;
            break;
        case 1:
            _Current = self.NewTopArray;
            break;
        case 2:
            _Current = self.ChineseTopArray;
            break;
        case 3:
            _Current = self.EnglishTopArray;
            break;
        case 4:
            _Current = self.JapaneseTopArray;
            break;
        case 5:
            _Current = self.ClassicOldArray;
            break;
        case 6:
            _Current = self.ClassicMovieArray;
            break;
        case 7:
            _Current = self.DancingArray;
            break;
        case 8:
            _Current = self.HotOldArray;
            break;
        case 9:
            _Current = self.DownloadListArray;
            break;
            
        default:
            _Current = self.TaskModelArray;
            break;
    }
    [_Controller setContent:_Current];
    
}


@end
