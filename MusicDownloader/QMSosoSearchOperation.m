//
//  QMSearchOperation.m
//  MusicDownloader
//
//  Created by user on 12-12-12.
//  Copyright (c) 2012年 crazyender. All rights reserved.
//
#import <Cocoa/Cocoa.h>
#import "QMSosoSearchOperation.h"
#include "HTMLParser.h"
#include "QMTaskModel.h"

@implementation QMSosoSearchOperation


-(id)initWithTypeAndName:(TopListType)type AndName:(NSString*)name
{
    if( self = [super init]){
        self->searchName = name;
        self->searchType = type;
        self->started = NO;
    }
    return self;
}

- (BOOL)isExecuting
{
    return self->started;
}



-(NSString*)ParserMusicDataAndGenerateDownloadLink:(NSString*)data
{
    if (data == nil) {
        return nil;
    }
    // data like this:
    // 1603824327@@Lonely@@善良的男人OST CD1@@金智秀@@1405075@@mp3@@100@@87@@FIhttp://stream10.qqmusic.qq.com/14442092.wma;;|||@@2694476499@@2011431147@@1
    NSArray *contents = [data componentsSeparatedByString:@"@@"];
    if ([contents count] < 8) {
        return nil;
    }
    NSString *trailUrl = [contents objectAtIndex:8];
    NSRange range = [trailUrl rangeOfString:@";"];
    trailUrl = [trailUrl substringWithRange:NSMakeRange(2, range.location-2)];
    // trail url is something like this: http://stream7.qqmusic.qq.com/13364721.wma
    // add 1 before stream*, and add 18 from **abcdef where abcdef should be the file id
    // after converting download url should be like this:
    // http://stream17.qqmusic.qq.com/31364721.mp3
    NSRange strStreamID = [trailUrl rangeOfString:@"stream"];
    strStreamID.location += [@"stream" length];
    strStreamID.length = 1;
    NSString *streamID = [trailUrl substringWithRange:strStreamID];
    NSRange strFileID = [trailUrl rangeOfString:@"qq.com/"];
    strFileID.location += [@"qq.com/" length];
    strFileID.length = 2;
    int fileIndex = [[trailUrl substringWithRange:strFileID] intValue] + 18;
    NSRange last = [trailUrl rangeOfString:@".wma"];
    strFileID.location += 2;
    strFileID.length = last.location-strFileID.location;
    NSString *fileID = [trailUrl substringWithRange:strFileID];
    NSString *trueUrl = [NSString stringWithFormat:@"http://stream1%@.qqmusic.qq.com/%d%@.mp3", streamID, fileIndex, fileID];
    
    return trueUrl;
}

-(void)SearchMusicWithName:(NSString*)name
{
    //NSMutableArray     *ret = [[NSMutableArray alloc] init];
    NSString    *format = [name stringByReplacingOccurrencesOfString:@" " withString:@"+"];
    NSString    *searchURL = [NSString stringWithFormat:@"http://cgi.music.soso.com/fcgi-bin/m.q?w=%@&p=1&source=1&t=1" , format];
    NSStringEncoding enc = CFStringConvertEncodingToNSStringEncoding(kCFStringEncodingGB_18030_2000);
    searchURL = [searchURL stringByAddingPercentEscapesUsingEncoding:enc];
    NSError     *error;
    NSString    *html = [NSString stringWithContentsOfURL:[NSURL URLWithString:searchURL] encoding:enc error:&error];
    
    HTMLParser *parser = [[HTMLParser alloc] initWithString:html Encoding:enc error:&error];
    if (error) {
        NSLog(@"Error: %@", error);
        return;
    }
    
    HTMLNode *bodyNode = [parser body];
    
    NSArray *musicNodesTable = [bodyNode findChildTags:@"tbody"];
    
    if ( [musicNodesTable count ] == 0 ) {
        return;
    }
    
    int index = 0;
    // 获得所有音乐
    NSArray *musicNodes = [ [musicNodesTable objectAtIndex:0] findChildTags:@"tr"];
    for (HTMLNode *tr in musicNodes) {
        QMTaskModel* model = [[QMTaskModel alloc]init];
        // 获得音乐的信息，包括名称，下载路径，大小等
        NSArray *musicInfo = [tr findChildTags:@"td"];
        for (HTMLNode *td in musicInfo) {
            NSString *subVal = [td innerText];
            if ([[td getAttributeNamed:@"class"] isEqualToString:@"data"]) {
                model.url  = [self ParserMusicDataAndGenerateDownloadLink:subVal];
            }else if ([[td getAttributeNamed:@"class"] isEqualToString:@"singer"]) {
                model.author = subVal;
            }else if ([[td getAttributeNamed:@"class"] isEqualToString:@"ablum"]) {
                model.alumb = subVal;
            }else if ([[td getAttributeNamed:@"class"] isEqualToString:@"size"]) {
                model.size = (int)([subVal floatValue] * 1024.0)  ;
            }else if ([[td getAttributeNamed:@"class"] isEqualToString:@"format"]) {
                model.title = [NSString stringWithFormat:@"%@.%@", model.title, subVal];
            }else if ([[td getAttributeNamed:@"class"] isEqualToString:@"song"]) {
                if (subVal == nil ) {
                    subVal = name;
                }
                model.title = subVal;
            }
        }
        model.TaskID = index++;
        model.NotDownloading = NO;
        model.ButtonTitle = @"下载";
        model.type = TopListSearch;
        //[ret addObject:model];
        //[self->observer performSelector:self->selector withObject:model];
        [self PerformItemFetchedEvent:model];
    }
    
}

-(void)GetTopListWithType:(TopListType)type
{
    
    //NSMutableArray* ret = [[NSMutableArray alloc]init];
    // 新歌榜: http://music.soso.com/portal/hit/sosoRank/new/hit_sosoRank_1.html
    // 华语榜: http://music.soso.com/portal/hit/sosoRank/chinese/hit_sosoRank_1.html
    // 欧美榜：http://music.soso.com/portal/hit/sosoRank/europ/hit_sosoRank_1.html
    // 日韩榜：http://music.soso.com/portal/hit/sosoRank/japan/hit_sosoRank_1.html
    // 经典老歌榜：http://music.soso.com/portal/hit/special/classic/hit_list_1.html
    // 影视金曲榜：http://music.soso.com/portal/hit/special/movie/hit_list_1.html
    // 舞曲榜：http://music.soso.com/portal/hit/special/dj/hit_list_1.html
    // 热门老歌：http://music.soso.com/portal/hit/special/couple/hit_list_1.html
    NSString* searchURL = @"";
    switch (type) {
        case TopListNew:
            searchURL = @"http://music.soso.com/portal/hit/sosoRank/new/hit_sosoRank_1.html";
            break;
        case TopListChinese:
            searchURL = @"http://music.soso.com/portal/hit/sosoRank/chinese/hit_sosoRank_1.html";
            break;
        case TopListEnglish:
            searchURL = @"http://music.soso.com/portal/hit/sosoRank/europ/hit_sosoRank_1.html";
            break;
        case TopListJapanese:
            searchURL = @"http://music.soso.com/portal/hit/sosoRank/japan/hit_sosoRank_1.html";
            break;
        case TopListClassicOld:
            searchURL = @"http://music.soso.com/portal/hit/special/classic/hit_list_1.html";
            break;
        case TopListClassicMovie:
            searchURL = @"http://music.soso.com/portal/hit/special/movie/hit_list_1.html";
            break;
        case TopListDancing:
            searchURL = @"http://music.soso.com/portal/hit/special/dj/hit_list_1.html";
            break;
        case TopListHotOld:
            searchURL = @"http://music.soso.com/portal/hit/special/couple/hit_list_1.html";
            break;
        default:
            return;
    }
    NSStringEncoding enc = CFStringConvertEncodingToNSStringEncoding(kCFStringEncodingGB_18030_2000);
    NSError     *error;
    NSString    *html = [NSString stringWithContentsOfURL:[NSURL URLWithString:searchURL] encoding:enc error:&error];
    HTMLParser *parser = [[HTMLParser alloc] initWithString:html Encoding:enc error:&error];
    if (error) {
        NSLog(@"Error: %@", error);
        return;
    }
    
    HTMLNode *bodyNode = [parser body];
    
    NSArray *musicNodesTable = [bodyNode findChildTags:@"ol"];
    if( [musicNodesTable count] == 0 )
        return ;
    
    int index = 0;
    for (HTMLNode * ol in musicNodesTable) {
        NSArray *dataCollection = [ol findChildTags:@"span"];
        if( [dataCollection count] == 0 )
            continue;
        
        for( HTMLNode* data in dataCollection )
        {
            if ([[data getAttributeNamed:@"class"] isEqualToString:@"data"])
            {
                // 每个 <span class='data'> 都是一首歌
                // 数据类似这样
                // 1486616673@@想你的夜@@432724765@@关喆@@3634180055@@身边的故事@@http://stream13.qqmusic.qq.com/31913719.mp3@@268
                QMTaskModel *model = [[QMTaskModel alloc]init];
                NSString *strData = [data innerText];
                NSArray *contents = [strData componentsSeparatedByString:@"@@"];
                if ([contents count] < 7) {
                    continue;
                }
                
                model.title = [contents objectAtIndex:1];
                model.url = [contents objectAtIndex:6];
                model.author = [contents objectAtIndex:3];
                model.alumb = [contents objectAtIndex:5];
                model.TaskID = index++;
                model.NotDownloading = NO;
                model.ButtonTitle = @"下载";
                model.size = 0;
                model.type = type;
                NSArray *tmp = [model.url componentsSeparatedByString:@"."];
                if ([tmp count] > 0) {
                    NSString *postFix = [tmp objectAtIndex:([tmp count]-1)];
                    model.title = [NSString stringWithFormat:@"%@.%@", model.title, postFix];
                }
                
                //[ret addObject:model];
                [self PerformItemFetchedEvent:model];
                //[self->observer performSelector:self->selector withObject:model];
            }
            
        }
        
    }
    
}

-(void)PerformItemFetchedEvent:(QMTaskModel*)item
{
    
    [[NSNotificationCenter defaultCenter] postNotificationName:QMItemFetched object:item];
    [NSThread sleepForTimeInterval:0.02];
}



-(void)main
{
    self->started = YES;
    if( self->searchType == TopListSearch){
        [self SearchMusicWithName:self->searchName];
    }else{
        [self GetTopListWithType:self->searchType];
    }
    self->started = NO;
}

@end
