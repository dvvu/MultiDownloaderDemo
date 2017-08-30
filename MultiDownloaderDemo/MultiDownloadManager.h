//
//  MultiDownloadManager.h
//  MultiDownloaderDemo
//
//  Created by Doan Van Vu on 8/25/17.
//  Copyright © 2017 Doan Van Vu. All rights reserved.
//

#import "MultiDownloadItemDelegate.h"
#import <Foundation/Foundation.h>
#import "DownloaderItem.h"

@interface MultiDownloadManager : NSObject

#pragma mark - singleton
+ (instancetype)sharedManager;

#pragma mark - MultiDownloadItemDelegate
@property (nonatomic) id<MultiDownloadItemDelegate> delegate;

#pragma mark - activeDownloaders
- (NSDictionary<NSURL *, DownloaderItem *> *) activeDownloaders;

#pragma mark - initBackgroundDownloadWithId
- (instancetype)initBackgroundDownloadWithId:(NSString *)identifier currentDownloadMaximum:(int)currentDownloadMaximum delegate:(id<MultiDownloadItemDelegate>) delegate delegateQueue:(NSOperationQueue *)queue;

#pragma mark - initDefaultDownloadWithDelegate
- (instancetype)initDefaultDownloadWithDelegate:(int)currentDownloadMaximum delegate:(id<MultiDownloadItemDelegate>)delegate delegateQueue:(NSOperationQueue *)queue;

#pragma mark - backgroundTransferCompletionHandler
@property (nonatomic) void(^backgroundTransferCompletionHandler)();

#pragma mark - fileExistsForUrl
- (BOOL)fileExistsForUrl:(NSURL *)sourceURL;

#pragma mark - fileExistsWithName
- (BOOL)fileExistsWithName:(NSString *)fileName;

#pragma mark - fileExistsWithName
- (BOOL)deleteFileForUrl:(NSURL *)sourceURL;

#pragma mark - fileExistsWithName
- (BOOL)deleteFileWithName:(NSString *)fileName;

#pragma mark - fileExistsWithName
- (NSString *)localPathForFile:(NSURL *)sourceURL;

#pragma mark - startDownloadFromURL
- (NSString *)startDownloadFromURL:(NSURL *)sourceURL;

#pragma mark - pauseDownloadFromURL
- (void)pauseDownloadFromURL:(NSString *)identifier;

#pragma mark - resumeDownloadFromURL
- (void)resumeDownloadFromURL:(NSString *)identifier;

#pragma mark - cancelDownloadFromURL
- (void)cancelDownloadFromURL:(NSString *)identifier;

@end
