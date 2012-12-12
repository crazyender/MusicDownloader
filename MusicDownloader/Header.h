//
//  Header.h
//  MusicDownloader
//
//  Created by user on 12-12-13.
//  Copyright (c) 2012年 crazyender. All rights reserved.
//

#ifndef MusicDownloader_Header_h
#define MusicDownloader_Header_h

typedef enum _TopListType
{
    TopListNone = -1,
    // 搜索列表 0
    TopListSearch = 0,
    // 新歌排行榜 1
    TopListNew = 1,
    // 华语排行榜 2
    TopListChinese = 2,
    // 欧美排行榜 3
    TopListEnglish = 3,
    // 日韩排行榜 4
    TopListJapanese = 4,
    // 经典老歌 5
    TopListClassicOld = 5,
    // 影视金曲 6
    TopListClassicMovie = 6,
    // 舞曲 7
    TopListDancing = 7,
    // 热门老歌 8
    TopListHotOld = 8,
    // 下载列表
    TopListDownload = 9,
    
}TopListType;

static NSString *QMItemFetched = @"QMTaskModelItemFetched";
static NSString *QMTabViewChanged = @"QMTabViewChanged";

#endif
