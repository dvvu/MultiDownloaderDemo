//
//  MultiDownloadItemDelegate.h
//  MultiDownloaderDemo
//
//  Created by Doan Van Vu on 8/25/17.
//  Copyright © 2017 Doan Van Vu. All rights reserved.
//

#ifndef MultiDownloadItemDelegate_h
#define MultiDownloadItemDelegate_h


#endif /* MultiDownloadItemDelegate_h */

#import <Foundation/Foundation.h>
#import "DownloaderItem.h"

@protocol MultiDownloadItemDelegate <NSObject>

#pragma mark - MultiDownloadItem
- (void)multiDownloadItem:(NSURL *)sourceUrl downloadStatus:(DownloaderItemStatus)status;

#pragma mark - MultiDownloadItem
- (void)multiDownloadItem:(DownloaderItem *)downloaderItem with:(NSURL *)sourceUrl didWriteData:(int64_t)bytesWritten totalBytesWritten:(int64_t)totalBytesWritten totalBytesExpectedToWrite:(int64_t)totalBytesExpectedToWrite;

#pragma mark - MultiDownloadItem
- (void)multiDownloadItem:(DownloaderItem *)downloaderItem didFinishDownloadFromURL:(NSURL *)sourceUrl toURL:(NSURL *)destUrl withError:(NSError *)error;

#pragma mark - MultiDownloadItem
- (void)multiDownloadItem:(DownloaderItem *)downloaderItem internetDisconnectFromURL:(NSURL *)sourceURL;

#pragma mark - MultiDownloadItem
- (void)multiDownloadItem:(DownloaderItem *)downloaderItem connectionTimeOutFromURL:(NSURL *)sourceURL;

@end
