//
//  MultiDownloadCellActionDelegate.h
//  MultiDownloadDemo
//
//  Created by Doan Van Vu on 8/24/17.
//  Copyright © 2017 Doan Van Vu. All rights reserved.
//

#import <Foundation/Foundation.h>

@protocol MultiDownloadCellActionDelegate <NSObject>

#pragma mark - startDownloadFromURL
- (void)startDownloadFromURL:(NSURL *)sourceURL;

#pragma mark - pauseDownloadFromURL
- (void)pauseDownloadFromURL:(NSURL *)sourceURL;

#pragma mark - resumeDownloadFromURL
- (void)resumeDownloadFromURL:(NSURL *)sourceURL;

#pragma mark - cancelDownloadFromURL
- (void)cancelDownloadFromURL:(NSURL *)sourceURL;

@end


