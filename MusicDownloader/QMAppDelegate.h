//
//  QMAppDelegate.h
//  fakeQQMusic
//
//  Created by user on 12-11-29.
//  Copyright (c) 2012年 crazyender. All rights reserved.
//

#import <Cocoa/Cocoa.h>
@class TaskModel;
@class QMService;
@class QMTabViewDelegate;
@class QMTaskModel;


@interface QMAppDelegate : NSObject <NSApplicationDelegate>{

    
    QMService *service;
    QMTabViewDelegate *tabViewDelegate;
    NSRecursiveLock *tabLock;

}

@property (assign) IBOutlet NSWindow *window;


@property (nonatomic, retain)   IBOutlet NSTextField *textName;

@property (nonatomic, retain)   IBOutlet NSTextField *textAuthor;

@property (nonatomic, retain)   IBOutlet NSButton *buttonSearch;

@property (nonatomic, retain)   IBOutlet NSTabView *tabView;

@property (nonatomic, retain)   IBOutlet NSBox  *boxContext;

@property (nonatomic, retain)   IBOutlet NSArrayController *arrayController;

@property (nonatomic, retain)   IBOutlet NSView *downloadView;

@property (nonatomic, retain)   IBOutlet NSView *normalView;

@property (nonatomic, retain)   IBOutlet NSCollectionView *collectionView;

@property (nonatomic, retain)   IBOutlet NSCollectionViewItem  *collectionViewItem;

-(void)insertObject:(TaskModel *)p inTaskModelArrayAtIndex:(NSUInteger)index;
-(void)removeObjectFromTaskModelArrayAtIndex:(NSUInteger)index;
-(void)setTaskModelArray:(NSMutableArray *)a;
-(NSMutableArray*)TaskModelArray;

- (IBAction)SearchButtonPressed:(NSButton*)sender;

- (IBAction)DownloadButtonPressed:(NSButton*)sender;

- (IBAction)SelectText:(id)sender;

-(void)OnTaskItemAdded:(NSNotification*)noti;
-(void)OnTabViewChanged:(NSNotification*)noti;

@end
