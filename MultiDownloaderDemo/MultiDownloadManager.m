//
//  MultiDownloadManager.m
//  MultiDownloaderDemo
//
//  Created by Doan Van Vu on 8/25/17.
//  Copyright © 2017 Doan Van Vu. All rights reserved.
//

#import "ThreadSafeMutableDictionary.h"
#import "ThreadSafeForMutableArray.h"
#import "MultiDownloadManager.h"
#import <UIKit/UIKit.h>

@interface MultiDownloadManager () <NSURLSessionTaskDelegate, NSURLSessionDownloadDelegate>

@property (nonatomic) ThreadSafeForMutableArray* pendingDownloadItems;
@property (nonatomic) ThreadSafeMutableDictionary* downloadItems;
@property (nonatomic) dispatch_queue_t downloadItemManageQueue;
@property (nonatomic) NSURLSession* downloadSession;
@property (nonatomic) int currentDownloadMaximum;

@end

@implementation MultiDownloadManager

+ (instancetype)sharedManager {
    
    static id sharedManager = nil;
    static dispatch_once_t onceToken;
    
    dispatch_once(&onceToken, ^{
        
        sharedManager = [[self alloc] init];
    });
    
    return sharedManager;
}

#pragma mark - initBackgroundDownloadWithId

- (instancetype)initBackgroundDownloadWithId:(NSString *)identifier currentDownloadMaximum:(int)currentDownloadMaximum delegate:(id<MultiDownloadItemDelegate>)delegate delegateQueue:(NSOperationQueue *)queue {
    
    self = [super init];
    
    if (self) {
        
        NSURLSessionConfiguration* configuration = [NSURLSessionConfiguration backgroundSessionConfigurationWithIdentifier:identifier];
        _downloadSession = [NSURLSession sessionWithConfiguration:configuration delegate:self delegateQueue:queue];
        _delegate = delegate;
        _currentDownloadMaximum = currentDownloadMaximum;
        [self setupDownloadTask];
    }
    return self;
}

#pragma mark - initDefaultDownloadWithDelegate

- (instancetype)initDefaultDownloadWithDelegate:(int)currentDownloadMaximum delegate:(id<MultiDownloadItemDelegate>)delegate delegateQueue:(NSOperationQueue *)queue {
    
    self = [super init];
    
    if (self) {
        
        NSURLSessionConfiguration* config = [NSURLSessionConfiguration defaultSessionConfiguration];
        _downloadSession = [NSURLSession sessionWithConfiguration:config delegate:self delegateQueue:queue];
        _delegate = delegate;
        _currentDownloadMaximum = currentDownloadMaximum;
        [self setupDownloadTask];
    }
    
    return self;
}

#pragma mark - setupDownloadTask

- (void)setupDownloadTask {
    
    _downloadItems = [[ThreadSafeMutableDictionary alloc] init];
    _downloadItemManageQueue = dispatch_queue_create("DOWNLOAD_MANAGER_QUEUE", DISPATCH_QUEUE_SERIAL);
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(terminalApp) name:UIApplicationWillTerminateNotification object:nil];
    
    // Get old tasks and cancel
    dispatch_semaphore_t semaphore = dispatch_semaphore_create(0);
    
    [_downloadSession getTasksWithCompletionHandler:^(NSArray* tasks, NSArray* uploadTasks, NSArray* downloadTasks) {
        
        for (NSURLSessionDownloadTask* downloadTask in downloadTasks) {
            
            [downloadTask cancel];
        }
        dispatch_semaphore_signal(semaphore);
    }];
    
    dispatch_semaphore_wait(semaphore, DISPATCH_TIME_FOREVER);
}

#pragma mark - terminalApp

- (void)terminalApp {
    
    [_downloadSession invalidateAndCancel];
}

#pragma mark - NSURLSessionDownloadDelegate

- (void)URLSession:(NSURLSession *)session downloadTask:(NSURLSessionDownloadTask *)downloadTask didFinishDownloadingToURL:(NSURL *)location {
    
//    NSURL* sourceURL = [[downloadTask originalRequest] URL];
    NSString* identifier = [NSString stringWithFormat:@"%lud",(unsigned long)[downloadTask taskIdentifier]];
    
    if (identifier) {
        
        DownloaderItem* downloaderItem = _downloadItems[identifier];
        
        if (downloaderItem) {
            
            NSURL* destinationLocation;
            NSError* error;
            BOOL success = YES;
            
            // if download failed -> success = NO
            if ([downloadTask.response isKindOfClass:[NSHTTPURLResponse class]]) {
                
                NSInteger statusCode = [(NSHTTPURLResponse*)downloadTask.response statusCode];
                
                if (statusCode >= 400) {
                    
                    NSLog(@"ERROR: HTTP status code %@", @(statusCode));
                    success = NO;
                }
            }
            
            if (success) {
                
                if (downloaderItem.directoryName) {
                    
                    destinationLocation = [[[self cachesDirectoryUrlPath] URLByAppendingPathComponent:downloaderItem.directoryName] URLByAppendingPathComponent:downloaderItem.fileName];
                    
                } else {
                    
                    destinationLocation = [[self cachesDirectoryUrlPath] URLByAppendingPathComponent:downloaderItem.fileName];
                }
                
                [self createDownloadTempDirectory];
                // Move downloaded item from tmp directory to te caches directory
                [[NSFileManager defaultManager] moveItemAtURL:location toURL:destinationLocation error:&error];
                
                if (error) {
                    
                    NSLog(@"Move item at URL ERROR: %@", error);
                } else {
                    
                    if (_delegate && [_delegate respondsToSelector:@selector(multiDownloadItem:didFinishDownloadFromURL:withError:)]) {
                        downloaderItem.downloadItemStatus = DownloadItemStatusCompleted;
                        [_delegate multiDownloadItem:downloaderItem didFinishDownloadFromURL:location withError:nil];
                    }
                }
            }
        }
        
        dispatch_async(_downloadItemManageQueue, ^{
            
            [_downloadItems removeObjectForkey:identifier];
        });
    }
}

#pragma mark - NSURLSessionDownloadDelegate

- (void)URLSession:(NSURLSession *)session downloadTask:(NSURLSessionDownloadTask *)downloadTask didWriteData:(int64_t)bytesWritten totalBytesWritten:(int64_t)totalBytesWritten totalBytesExpectedToWrite:(int64_t)totalBytesExpectedToWrite {
    
    NSString* identifier = [NSString stringWithFormat:@"%lud",(unsigned long)[downloadTask taskIdentifier]];
    
    if (_delegate && [_delegate respondsToSelector:@selector(multiDownloadItem:didWriteData:totalBytesWritten:totalBytesExpectedToWrite:)]) {
        
        DownloaderItem* downloaderItem = _downloadItems[identifier];
        
        if (downloaderItem.downloadItemStatus == DownloadItemStatusNotStarted) {
            
            downloaderItem.downloadItemStatus = DownloadItemStatusStarted;
        }
        
        [_delegate multiDownloadItem:downloaderItem didWriteData:bytesWritten totalBytesWritten:totalBytesWritten totalBytesExpectedToWrite:totalBytesExpectedToWrite];
    }
}

#pragma mark - NSURLSessionTaskDelegate

- (void)URLSession:(NSURLSession *)session task:(NSURLSessionTask *)downloadTask didCompleteWithError:(NSError *)error {
    
    if (!error) {
        
        return;
    }
    
    NSString* identifier = [NSString stringWithFormat:@"%lud",(unsigned long)[downloadTask taskIdentifier]];
    
    switch ([error code]) {
            
        case NSURLErrorCancelled:
            
            NSLog(@"FinishDownload - Error: %@",[error debugDescription]);
            break;
        case kCFHostErrorUnknown:
            
            // Could not found directory to save file
            break;
        case NSURLErrorNotConnectedToInternet:
            
            // Cannot connect to the internet
            break;
        case NSURLErrorTimedOut:
            
            // Time out connection
            break;
        default:
            break;
    }
    
    if (_delegate && [_delegate respondsToSelector:@selector(multiDownloadItem:didFinishDownloadFromURL:withError:)]) {
        
        DownloaderItem* downloaderItem = _downloadItems[identifier];
        [_delegate multiDownloadItem:downloaderItem didFinishDownloadFromURL:nil withError:error];
    }
    
    if (identifier) {
        
        dispatch_async(_downloadItemManageQueue, ^{
            
            [_downloadItems removeObjectForkey:identifier];
        });
    }
}

#pragma mark - getIdForActiveDownloadURL...

- (NSInteger)getIdForActiveDownloadURL:(NSURL *)sourceURL {
    
    NSInteger aFoundDownloadID = -1;
    NSArray* aDownloadKeysArray = [_downloadItems allKeys];
    
    for (NSNumber* aDownloadID in aDownloadKeysArray) {
        
        DownloaderItem* aDownloadItem = [_downloadItems objectForKeyedSubscript:aDownloadID];
        
        if ([aDownloadItem.sourceURL isEqual:sourceURL]) {
            
            aFoundDownloadID = [aDownloadID unsignedIntegerValue];
            break;
        }
    }
    return aFoundDownloadID;
}

#pragma mark - cachesDirectoryUrlPath

- (NSURL *)cachesDirectoryUrlPath {
    
    NSArray* paths = NSSearchPathForDirectoriesInDomains(NSCachesDirectory, NSUserDomainMask, YES);
    NSString* cachesDirectory = [paths objectAtIndex:0];
    NSURL* cachesDirectoryUrl = [NSURL fileURLWithPath:cachesDirectory];
    
    return cachesDirectoryUrl;
}

#pragma mark - startDownloadFromURL

- (NSString *)startDownloadFromURL:(NSURL *)sourceURL {
    
    [self createDownloadTempDirectory];
   
    if (_downloadItems.count > _currentDownloadMaximum) {
        
        
    } else {
        
        
    }
    
    NSURLRequest* request = [NSURLRequest requestWithURL:sourceURL cachePolicy:NSURLRequestReloadIgnoringCacheData timeoutInterval:10.0];
    NSURLSessionDownloadTask* downloadTask = [_downloadSession downloadTaskWithRequest:request];
    DownloaderItem* downloaderItem = [[DownloaderItem alloc] initWithActiveDownloadTask:downloadTask with:sourceURL session:_downloadSession];
    
    downloaderItem = [[DownloaderItem alloc] initWithActiveDownloadTask:downloadTask with:sourceURL session:_downloadSession];
    downloaderItem.startDate = [NSDate date];
    downloaderItem.sourceURL = sourceURL;
    downloaderItem.fileName = [sourceURL lastPathComponent];
    downloaderItem.downloadItemStatus = DownloadItemStatusStarted;
    [downloaderItem.downloadTask resume];
    
    dispatch_async(_downloadItemManageQueue, ^{
        
        [_downloadItems setObject:downloaderItem forKeyedSubscript:downloaderItem.identifier];
    });
    
    return downloaderItem.identifier;
}

#pragma mark - pauseDownloadFromURL

- (void)pauseDownloadFromURL:(NSString *)identifier {
    
    DownloaderItem* downloaderItem = _downloadItems[identifier];
    downloaderItem.downloadItemStatus = DownloadItemStatusPaused;
    [downloaderItem.downloadTask suspend];
    [_delegate multiDownloadItem:downloaderItem downloadStatus:DownloadItemStatusPaused];
}

#pragma mark - resumeDownloadFromURL

- (void)resumeDownloadFromURL:(NSString *)identifier {
    
    DownloaderItem* downloaderItem = _downloadItems[identifier];
    downloaderItem.downloadItemStatus = DownloadItemStatusStarted;
    [downloaderItem.downloadTask resume];
    [_delegate multiDownloadItem:downloaderItem downloadStatus:DownloadItemStatusStarted];
}

#pragma mark - cancelDownloadFromURL

- (void)cancelDownloadFromURL:(NSString *)identifier {
    
    DownloaderItem* downloaderItem = _downloadItems[identifier];
    downloaderItem.downloadItemStatus = DownloadItemStatusCancelled;
    [downloaderItem.downloadTask cancel];
    [_delegate multiDownloadItem:downloaderItem downloadStatus:DownloadItemStatusCancelled];
}

#pragma mark - activeDownloaders

- (NSDictionary<NSURL *, DownloaderItem *> *) activeDownloaders {
    
    return [_downloadItems toNSDictionary];
}

#pragma mark - createDownloadTempDirectory

- (void)createDownloadTempDirectory {
    
    // Get Caches directory
    NSArray* cacheDirectory = NSSearchPathForDirectoriesInDomains(NSCachesDirectory, NSAllDomainsMask, YES);
    NSString* path = [cacheDirectory firstObject];
    path = [path stringByAppendingPathComponent:[NSString stringWithFormat:@"com.apple.nsurlsessiond/Downloads/%@",[[NSBundle mainBundle] bundleIdentifier]]];
    
    // Create new directory if not existed
    if (![[NSFileManager defaultManager] fileExistsAtPath:path]) {
        
        [[NSFileManager defaultManager] createDirectoryAtPath:path withIntermediateDirectories:YES attributes:nil error:nil];
    }
}

/* Condition to check file Exits */

#pragma mark - fileExistsForUrl

- (BOOL)fileExistsForUrl:(NSURL *)sourceURL {
    
    return [self fileExistsForUrl:sourceURL inDirectory:nil];
}

#pragma mark - fileExistsForUrl

- (BOOL)fileExistsForUrl:(NSURL *)sourceURL inDirectory:(NSString *)directoryName {
    
    return [self fileExistsWithName:[sourceURL lastPathComponent] inDirectory:directoryName];
}

#pragma mark - fileExistsWithName

- (BOOL)fileExistsWithName:(NSString *)fileName {
    
    return [self fileExistsWithName:fileName inDirectory:nil];
}

#pragma mark - fileExistsWithName...

- (BOOL)fileExistsWithName:(NSString *)fileName inDirectory:(NSString *)directoryName {
    
    BOOL exists = NO;
    
    NSArray* paths = NSSearchPathForDirectoriesInDomains(NSCachesDirectory, NSUserDomainMask, YES);
    NSString* cachesDirectory = [paths objectAtIndex:0];
    NSLog(@"%@",cachesDirectory);
    
    // if no directory was provided, we look by default in the base cached dir
    if ([[NSFileManager defaultManager] fileExistsAtPath:[[cachesDirectory stringByAppendingPathComponent:directoryName] stringByAppendingPathComponent:fileName]]) {
        
        exists = YES;
    }
    
    return exists;
}

#pragma mark - deleteFileForUrl

- (BOOL)deleteFileForUrl:(NSURL *)sourceURL {
    
    return [self deleteFileForUrl:sourceURL inDirectory:nil];
}

#pragma mark - deleteFileForUrl

- (BOOL)deleteFileForUrl:(NSURL *)sourceURL inDirectory:(NSString *)directoryName {
    
    return [self deleteFileWithName:[sourceURL lastPathComponent] inDirectory:directoryName];
}

#pragma mark - deleteFileWithName

- (BOOL)deleteFileWithName:(NSString *)fileName {
    
    return [self deleteFileWithName:fileName inDirectory:nil];
}

#pragma mark - deleteFileWithName

- (BOOL)deleteFileWithName:(NSString *)fileName inDirectory:(NSString *)directoryName {
    
    BOOL deleted = NO;
    NSError* error;
    NSURL* fileLocation;
    
    if (directoryName) {
        
        fileLocation = [[[self cachesDirectoryUrlPath] URLByAppendingPathComponent:directoryName] URLByAppendingPathComponent:fileName];
    } else {
        
        fileLocation = [[self cachesDirectoryUrlPath] URLByAppendingPathComponent:fileName];
    }
    
    if ([self fileExistsWithName:fileName inDirectory:directoryName]) {
        
        // Move downloaded item from tmp directory to te caches directory
        [[NSFileManager defaultManager] removeItemAtURL:fileLocation error:&error];
        
        if (error) {
            
            deleted = NO;
            NSLog(@"Error deleting file: %@", error);
        } else {
            
            deleted = YES;
        }
    }
    
    return deleted;
}

#pragma mark - fileDownloadCompletedForUrl...

- (NSString *)localPathForFile:(NSURL *)sourceURL {
    
    return [self localPathForFile:sourceURL inDirectory:nil];
}

#pragma mark - fileDownloadCompletedForUrl...

- (NSString *)localPathForFile:(NSURL *)sourceURL inDirectory:(NSString *)directoryName {
    
    NSString* fileName = [sourceURL lastPathComponent];
    NSArray* paths = NSSearchPathForDirectoriesInDomains(NSCachesDirectory, NSUserDomainMask, YES);
    NSString* cachesDirectory = [paths objectAtIndex:0];
    
    return [[cachesDirectory stringByAppendingPathComponent:directoryName] stringByAppendingPathComponent:fileName];
}

#pragma mark - Background download

- (void)URLSessionDidFinishEventsForBackgroundURLSession:(NSURLSession *)session {
    
    // Check if all download tasks have been finished.
    [session getTasksWithCompletionHandler:^(NSArray* dataTasks, NSArray* uploadTasks, NSArray* downloadTasks) {
        
        if ([downloadTasks count] == 0) {
            
            if (_backgroundTransferCompletionHandler != nil) {
                
                // Copy locally the completion handler.
                void(^completionHandler)() = _backgroundTransferCompletionHandler;
                
                [[NSOperationQueue mainQueue] addOperationWithBlock:^{
                    
                    // Call the completion handler to tell the system that there are no other background transfers.
                    completionHandler();
                }];
                
                // Make nil the backgroundTransferCompletionHandler.
                _backgroundTransferCompletionHandler = nil;
            }
        }
    }];
}

@end
