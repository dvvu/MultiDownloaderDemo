//
//  MultiDownloaderManager.h
//  MultiDownloaderDemo
//
//  Created by Doan Van Vu on 9/5/17.
//  Copyright © 2017 Doan Van Vu. All rights reserved.
//

#import "MultiDownloaderItemDelegate.h"
#import <Foundation/Foundation.h>
#import "DownloaderItem.h"

@interface MultiDownloaderManager : NSObject

#pragma mark - singleton
+ (instancetype)sharedManager;

#pragma mark - backgroundTransferCompletionHandler
@property (nonatomic) void(^backgroundTransferCompletionHandler)();

#pragma mark - MultiDownloadItemDelegate
@property (nonatomic) id<MultiDownloaderItemDelegate> delegate;

#pragma mark - initBackgroundDownloadWithId
- (instancetype)initBackgroundDownloadWithId:(NSString *)identifier currentDownloadMaximum:(int)currentDownloadMaximum delegate:(id<MultiDownloaderItemDelegate>) delegate delegateQueue:(NSOperationQueue *)queue;

#pragma mark - initDefaultDownloadWithDelegate
- (instancetype)initDefaultDownloadWithDelegate:(int)currentDownloadMaximum delegate:(id<MultiDownloaderItemDelegate>)delegate delegateQueue:(NSOperationQueue *)queue;

#pragma mark - startDownloadFromURL
- (NSString *)startDownloadFromURL:(NSURL *)sourceURL;

#pragma mark - pauseDownloadWithItemID
- (void)pauseDownloadWithItemID:(NSString *)identifier;

#pragma mark - resumeDownloadWithItemID
- (void)resumeDownloadWithItemID:(NSString *)identifier;

#pragma mark - cancelDownloadWithItemID
- (void)cancelDownloadWithItemID:(NSString *)identifier;

#pragma mark - fileExistsWithName
- (BOOL)fileExistsWithName:(NSString *)fileName;

#pragma mark - fileExistsForUrl
- (BOOL)fileExistsForUrl:(NSURL *)sourceURL;

@end
