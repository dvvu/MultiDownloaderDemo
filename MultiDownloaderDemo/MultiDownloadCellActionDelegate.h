//
//  MultiDownloadCellActionDelegate.h
//  MultiDownloadDemo
//
//  Created by Doan Van Vu on 8/24/17.
//  Copyright © 2017 Doan Van Vu. All rights reserved.
//

#import <Foundation/Foundation.h>

@protocol MultiDownloadCellActionDelegate <NSObject>

#pragma mark - cancelDownloadWithItemID
- (void)startDownloadFromURL:(NSURL *)sourceURL;

#pragma mark - cancelDownloadWithItemID
- (void)pauseDownloadWithItemID:(NSString *)identifier;

#pragma mark - cancelDownloadWithItemID
- (void)resumeDownloadWithItemID:(NSString *)identifier;

#pragma mark - cancelDownloadWithItemID
- (void)cancelDownloadWithItemID:(NSString *)identifier;

@end


