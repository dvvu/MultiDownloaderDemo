//
//  MultiDownloaderItemDelegate.h
//  MultiDownloaderDemo
//
//  Created by Doan Van Vu on 9/5/17.
//  Copyright © 2017 Doan Van Vu. All rights reserved.
//

#ifndef MultiDownloaderItemDelegate_h
#define MultiDownloaderItemDelegate_h

#import <Foundation/Foundation.h>
#import "DownloaderItem.h"

#endif /* MultiDownloaderItemDelegate_h */

@protocol MultiDownloaderItemDelegate <NSObject>

#pragma mark - MultiDownloadItem
- (void)multiDownloaderItem:(DownloaderItem *)downloaderItem didWriteData:(int64_t)bytesWritten totalBytesWritten:(int64_t)totalBytesWritten totalBytesExpectedToWrite:(int64_t)totalBytesExpectedToWrite;

#pragma mark - MultiDownloadItem
- (void)multiDownloaderItem:(DownloaderItem *)downloaderItem didFinishDownloadFromURL:(NSURL *)destUrl withError:(NSError *)error;

#pragma mark - MultiDownloadItem
- (void)multiDownloaderItem:(DownloaderItem *)downloaderItem downloadStatus:(DownloaderItemStatus)status;

@end
