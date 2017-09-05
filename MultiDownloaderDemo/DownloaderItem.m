//
//  DownloaderItem.m
//  MultiDownloaderDemo
//
//  Created by Doan Van Vu on 8/25/17.
//  Copyright © 2017 Doan Van Vu. All rights reserved.
//

#import "DownloaderItem.h"

@interface DownloaderItem ()

@end

@implementation DownloaderItem

#pragma mark - initWithUrl

- (instancetype)initWithActiveDownloadTask:(NSURLSessionDownloadTask *)downloadTask with:(NSURL *)sourceURL session:(NSURLSession *)session {
    
    self = [super init];
    
    if (self) {
        
        _receivedFileSizeInBytes = 0;
        _expectedFileSizeInBytes = 0;
        _resumedFileSizeInBytes = 0;
        _bytesPerSecondSpeed = 0;
        _downloadItemStatus = DownloadItemStatusNotStarted;
        _downloadTask = downloadTask;
        _directoryName = @"";
        _fileName = @"";
        _sourceURL = sourceURL;
        _identifier = [NSString stringWithFormat:@"%lud",(unsigned long)downloadTask.taskIdentifier];
    }
    
    return self;
}

@end
