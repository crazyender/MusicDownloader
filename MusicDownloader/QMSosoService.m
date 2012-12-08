//
//  QMSosoService.m
//  fakeQQMusic
//
//  Created by user on 12-12-6.
//  Copyright (c) 2012年 crazyender. All rights reserved.
//

#import "QMSosoService.h"
#include "HTMLParser.h"
#include "QMTaskModel.h"

@implementation QMSosoService

-(id)init
{
    self = [super init];
    receivedData = [NSMutableData data];
    return self;
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

-(NSMutableArray*)SearchMusicWithName:(NSString*)name asWellAsAuthor:(NSString*)author
{
    NSMutableArray     *ret = [[NSMutableArray alloc] init];
    NSString    *format = [name stringByReplacingOccurrencesOfString:@" " withString:@"+"];
    NSString    *searchURL = [NSString stringWithFormat:@"http://cgi.music.soso.com/fcgi-bin/m.q?w=%@&p=1&source=1&t=1" , format];
    NSStringEncoding enc = CFStringConvertEncodingToNSStringEncoding(kCFStringEncodingGB_18030_2000);
    searchURL = [searchURL stringByAddingPercentEscapesUsingEncoding:enc];
    NSError     *error;
    NSString    *html = [NSString stringWithContentsOfURL:[NSURL URLWithString:searchURL] encoding:enc error:&error];
    
    HTMLParser *parser = [[HTMLParser alloc] initWithString:html Encoding:enc error:&error];
    if (error) {
        NSLog(@"Error: %@", error);
        return ret;
    }
    
    HTMLNode *bodyNode = [parser body];
    
    NSArray *musicNodesTable = [bodyNode findChildTags:@"tbody"];
    
    if ( [musicNodesTable count ] == 0 ) {
        return ret;
    }
    
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
        model.TaskID = [ret count];
        [ret addObject:model];
    }
      
    return ret;
}

-(void)BeginDownload:(QMTaskModel*)model
{
    NSDictionary *additionalHeaders = [NSDictionary dictionaryWithObjectsAndKeys:
                @"http://soso.music.qq.com/fcgi-bin/fcg_song.fcg", @"Referer",
                @"*/*", @"Accept",
                @"1", @"DNT",
                @"Mozilla/5.0 (compatible; MSIE 9.0; Windows NT 6.1; WOW64; Trident/5.0; MALC)", @"User-Agent",
                @"qqmusic_fromtag=10; qqmusic_sosokey=4D96476733A6D833E90FEA9E590408D171B92452775E15FB", @"Cookie",
                nil];
    [model BeginDownload:additionalHeaders];
}


@end
