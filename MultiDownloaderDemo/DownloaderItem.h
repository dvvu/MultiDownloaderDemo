//
//  DownloaderItem.h
//  MultiDownloaderDemo
//
//  Created by Doan Van Vu on 8/25/17.
//  Copyright © 2017 Doan Van Vu. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "DownloaderItemStatus.h"

@interface DownloaderItem : NSObject

#pragma mark - initWithActiveDownloadTask
- (instancetype)initWithActiveDownloadTask:(NSURLSessionDownloadTask *)downloadTask with:(NSURL *)sourceURL session:(NSURLSession *)session;

#pragma mark - receivedFileSizeInBytes
@property (nonatomic, assign) int64_t receivedFileSizeInBytes;

#pragma mark - expectedFileSizeInBytes
@property (nonatomic, assign) int64_t expectedFileSizeInBytes;

#pragma mark - resumedFileSizeInBytes
@property (nonatomic, assign) int64_t resumedFileSizeInBytes;

#pragma mark - bytesPerSecondSpeed
@property (nonatomic, assign) NSUInteger bytesPerSecondSpeed;

#pragma mark - progress
@property (nonatomic, strong, readonly) NSProgress* progress;

#pragma mark - isDownloading
@property (nonatomic) DownloaderItemStatus downloadItemStatus;

#pragma mark - downloadTask
@property (nonatomic) NSURLSessionDownloadTask* downloadTask;

#pragma mark - directoryName
@property (copy, nonatomic) NSString* directoryName;

#pragma mark - fileName
@property (copy, nonatomic) NSString* fileName;

#pragma mark - startDate
@property (copy, nonatomic) NSDate* startDate;

#pragma mark - url
@property (nonatomic) NSURL* sourceURL;

@end
