//
//  QMTabViewDelegate.h
//  MusicDownloader
//
//  Created by user on 12-12-9.
//  Copyright (c) 2012年 crazyender. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface QMTabViewDelegate : NSObject<NSTabViewDelegate>
{
    // data for 搜索结果 0
    NSMutableArray *_TaskModelArray;
    // data for 新歌排行榜 1
    NSMutableArray *_NewTopArray;
    // data for 华语排行榜 2
    NSMutableArray *_ChineseTopArray;
    // data for 欧美排行榜 3
    NSMutableArray *_EnglishTopArray;
    // data for 日韩排行榜 4
    NSMutableArray *_JapaneseTopArray;
    // data for 经典老歌 5
    NSMutableArray *_ClassicOldArray;
    // data for 影视金曲 6
    NSMutableArray *_ClassicMovieArray;
    // data for 舞曲 7
    NSMutableArray *_DancingArray;
    // data for 热门老歌 8
    NSMutableArray *_HotOldArray;
    // data for 下载列表 9
    NSMutableArray *_DownloadListArray;
    
    NSMutableArray *_Current;
    
    NSArrayController *_Controller;
}
@property (atomic) NSMutableArray *TaskModelArray;
@property (atomic) NSMutableArray *NewTopArray;
@property (atomic) NSMutableArray *ChineseTopArray;
@property (atomic) NSMutableArray *EnglishTopArray;
@property (atomic) NSMutableArray *JapaneseTopArray;
@property (atomic) NSMutableArray *ClassicOldArray;
@property (atomic) NSMutableArray *ClassicMovieArray;
@property (atomic) NSMutableArray *DancingArray;
@property (atomic) NSMutableArray *HotOldArray;
@property (atomic) NSMutableArray *DownloadListArray;


+(id) initWithViewController:(NSArrayController*)controller;
-(NSMutableArray*)SelectedArray;
- (void)tabView:(NSTabView *)tabView didSelectTabViewItem:(NSTabViewItem *)tabViewItem;

@end
