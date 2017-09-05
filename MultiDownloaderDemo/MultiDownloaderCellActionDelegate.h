//
//  MultiDownloaderCellActionDelegate.h
//  MultiDownloaderDemo
//
//  Created by Doan Van Vu on 9/5/17.
//  Copyright © 2017 Doan Van Vu. All rights reserved.
//

#ifndef MultiDownloaderCellActionDelegate_h
#define MultiDownloaderCellActionDelegate_h

#endif /* MultiDownloaderCellActionDelegate_h */

#import <Foundation/Foundation.h>

@protocol MultiDownloaderCellActionDelegate <NSObject>

#pragma mark - cancelDownloadWithItemID
- (void)startDownloadFromURL:(NSURL *)sourceURL;

#pragma mark - cancelDownloadWithItemID
- (void)pauseDownloadWithItemID:(NSString *)identifier;

#pragma mark - cancelDownloadWithItemID
- (void)resumeDownloadWithItemID:(NSString *)identifier;

#pragma mark - cancelDownloadWithItemID
- (void)cancelDownloadWithItemID:(NSString *)identifier;

@end
