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

@property (nonatomic) ThreadSafeMutableDictionary* currentActiveDownloadItems;
@property (nonatomic) ThreadSafeForMutableArray* pendingDownloadItems;
@property (nonatomic) ThreadSafeForMutableArray* resumeDownloadItems;
@property (nonatomic) dispatch_queue_t downloadItemManageQueue;
@property (nonatomic) dispatch_queue_t removeItemQueue;
@property (nonatomic) NSURLSession* downloadSession;
@property (nonatomic) int currentDownloadMaximum;

@end

@implementation MultiDownloadManager

+ (instancetype)sharedManager {
    
    static MultiDownloadManager* sharedInstance = nil;
    static dispatch_once_t onceToken;
    
    dispatch_once(&onceToken, ^{
        
        sharedInstance = [[self alloc] init];
    });
    
    return sharedInstance;
}

#pragma mark - initBackgroundDownloadWithId

- (instancetype)initBackgroundDownloadWithId:(NSString *)identifier currentDownloadMaximum:(int)currentDownloadMaximum delegate:(id<MultiDownloadItemDelegate>)delegate delegateQueue:(NSOperationQueue *)queue {
    
    static dispatch_once_t onceToken;
    
    dispatch_once(&onceToken, ^{
    
        NSURLSessionConfiguration* configuration = [NSURLSessionConfiguration backgroundSessionConfigurationWithIdentifier:identifier];
        _downloadSession = [NSURLSession sessionWithConfiguration:configuration delegate:self delegateQueue:queue];
        _delegate = delegate;
        _currentDownloadMaximum = currentDownloadMaximum;
        [self setupDownloadTask];
    });
    
    return self;
}

#pragma mark - initDefaultDownloadWithDelegate

- (instancetype)initDefaultDownloadWithDelegate:(int)currentDownloadMaximum delegate:(id<MultiDownloadItemDelegate>)delegate delegateQueue:(NSOperationQueue *)queue {
    
    static dispatch_once_t onceToken;
    
    dispatch_once(&onceToken, ^{
        
        NSURLSessionConfiguration* configurationDefault = [NSURLSessionConfiguration defaultSessionConfiguration];
        _downloadSession = [NSURLSession sessionWithConfiguration:configurationDefault delegate:self delegateQueue:queue];
        _delegate = delegate;
        _currentDownloadMaximum = currentDownloadMaximum;
        [self setupDownloadTask];
    });
    
    return self;
}

#pragma mark - setupDownloadTask

- (void)setupDownloadTask {
    
    _downloadItemManageQueue = dispatch_queue_create("DOWNLOAD_MANAGER_QUEUE", DISPATCH_QUEUE_SERIAL);
    _removeItemQueue = dispatch_queue_create("REMOVEITEM_QUEUE", DISPATCH_QUEUE_SERIAL);
    _currentActiveDownloadItems = [[ThreadSafeMutableDictionary alloc] init];
    _pendingDownloadItems = [[ThreadSafeForMutableArray alloc] init];
    _resumeDownloadItems = [[ThreadSafeForMutableArray alloc] init];
    
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
    
    NSString* identifier = [NSString stringWithFormat:@"%lud",(unsigned long)[downloadTask taskIdentifier]];
    
    if (identifier) {
        
        DownloaderItem* downloaderItem = [_currentActiveDownloadItems getObjectForKey:identifier];
        
        if (!downloaderItem) {
            
            NSPredicate* predicate = [NSPredicate predicateWithFormat:@"identifier contains[cd] %@", identifier];
            
            if ([_resumeDownloadItems filteredArrayUsingPredicate:predicate].count > 0) {
                
                downloaderItem = [_resumeDownloadItems filteredArrayUsingPredicate:predicate][0];
            }
        }
        
        NSURL* destinationLocation;
        
        if (downloaderItem.directoryName) {
            
            destinationLocation = [[[self cachesDirectoryUrlPath] URLByAppendingPathComponent:downloaderItem.directoryName] URLByAppendingPathComponent:downloaderItem.fileName];
        } else {
            
            destinationLocation = [[self cachesDirectoryUrlPath] URLByAppendingPathComponent:downloaderItem.fileName];
        }
        
        [self createDownloadTempDirectory];
        
        dispatch_sync(_removeItemQueue, ^{
            
            [[NSFileManager defaultManager] moveItemAtURL:location toURL:destinationLocation error:nil];
            [self deleteFileWithName:downloaderItem.fileName];
        });
        
        // download completed.
        if (_delegate && [_delegate respondsToSelector:@selector(multiDownloadItem:didFinishDownloadFromURL:withError:)]) {
            
            downloaderItem.downloadItemStatus = DownloadItemStatusCompleted;
            [_delegate multiDownloadItem:downloaderItem didFinishDownloadFromURL:location withError:nil];
        }
        
        [_currentActiveDownloadItems removeObjectForkey:identifier];
        
        if(_pendingDownloadItems.count > 0) {
            
            DownloaderItem* nextDownloaderItem = [_pendingDownloadItems objectAtIndex:0];
            [nextDownloaderItem.downloadTask resume];
            
            [_currentActiveDownloadItems setObject:nextDownloaderItem forKey:nextDownloaderItem.identifier];
            [_pendingDownloadItems removeObject:nextDownloaderItem];
        }
    }
}

#pragma mark - NSURLSessionDownloadDelegate

- (void)URLSession:(NSURLSession *)session downloadTask:(NSURLSessionDownloadTask *)downloadTask didWriteData:(int64_t)bytesWritten totalBytesWritten:(int64_t)totalBytesWritten totalBytesExpectedToWrite:(int64_t)totalBytesExpectedToWrite {
    
    NSString* identifier = [NSString stringWithFormat:@"%lud",(unsigned long)[downloadTask taskIdentifier]];
    
    if (_delegate && [_delegate respondsToSelector:@selector(multiDownloadItem:didWriteData:totalBytesWritten:totalBytesExpectedToWrite:)]) {
        
        DownloaderItem* downloaderItem = [_currentActiveDownloadItems getObjectForKey:identifier];
        
        // check case delay when click suspend.
        NSLog(@"current %lu - pending %lu",(unsigned long)_currentActiveDownloadItems.count, (unsigned long)_pendingDownloadItems.count);
        downloaderItem.isActiveDownload = YES;
        
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
}

#pragma mark - startDownloadFromURL

- (NSString *)startDownloadFromURL:(NSURL *)sourceURL {
    
    [self createDownloadTempDirectory];
    
    NSURLRequest* request = [NSURLRequest requestWithURL:sourceURL];
    NSURLSessionDownloadTask* downloadTask = [_downloadSession downloadTaskWithRequest:request];
    DownloaderItem* downloaderItem = [[DownloaderItem alloc] initWithActiveDownloadTask:downloadTask with:sourceURL session:_downloadSession];
    
    downloaderItem.startDate = [NSDate date];
    downloaderItem.sourceURL = sourceURL;
    downloaderItem.fileName = [sourceURL lastPathComponent];
    NSLog(@"%@",downloaderItem.identifier);
    
    if (_currentActiveDownloadItems.count >= _currentDownloadMaximum) {
        
        NSLog(@"pending..... %@",downloaderItem.identifier);
        [_pendingDownloadItems addObject:downloaderItem];
    } else {
        
        [downloaderItem.downloadTask resume];
        [_currentActiveDownloadItems setObject:downloaderItem forKey:downloaderItem.identifier];
    }

    return downloaderItem.identifier;
}

#pragma mark - pauseDownloadWithItemID

- (void)pauseDownloadWithItemID:(NSString *)identifier {
    
    DownloaderItem* downloaderItem = [_currentActiveDownloadItems getObjectForKey:identifier];
 
    if (downloaderItem) {
        
        // pause currentTask running
        downloaderItem.downloadItemStatus = DownloadItemStatusPaused;
        [downloaderItem.downloadTask suspend];
        [_delegate multiDownloadItem:downloaderItem downloadStatus:DownloadItemStatusPaused];
        
        // add into resumeList
        [_resumeDownloadItems addObject:downloaderItem];
        
        // remove out of activeList
        [_currentActiveDownloadItems removeObjectForkey:identifier];
        
        // check PendingList exits -> run next task.
        if (_pendingDownloadItems.count > 0) {
            
            DownloaderItem* nextDownloaderItem = [_pendingDownloadItems objectAtIndex:0];
            nextDownloaderItem.downloadItemStatus = DownloadItemStatusStarted;
            [nextDownloaderItem.downloadTask resume];
            [_delegate multiDownloadItem:nextDownloaderItem downloadStatus:DownloadItemStatusStarted];
            [_currentActiveDownloadItems setObject:nextDownloaderItem forKey:nextDownloaderItem.identifier];
            
            //remove out of pendingList
            [_pendingDownloadItems removeObject:nextDownloaderItem];
        }
    } else {
        
        // pause pending Task
        // get it and change status
        NSPredicate* predicate = [NSPredicate predicateWithFormat:@"identifier contains[cd] %@", identifier];
        
        if ([_pendingDownloadItems filteredArrayUsingPredicate:predicate].count > 0) {
            
            DownloaderItem* pendingDownloaderItem = [_pendingDownloadItems filteredArrayUsingPredicate:predicate][0];
            pendingDownloaderItem.downloadItemStatus = DownloadItemStatusPaused;
            [downloaderItem.downloadTask suspend];
            [_delegate multiDownloadItem:pendingDownloaderItem downloadStatus:DownloadItemStatusPaused];
            
            // add into resumeList
            [_resumeDownloadItems addObject:pendingDownloaderItem];
            //remove out of pendingList
            [_pendingDownloadItems removeObject:pendingDownloaderItem];
        }
    }
}

#pragma mark - resumeDownloadWithItemID

- (void)resumeDownloadWithItemID:(NSString *)identifier {
    
    NSPredicate* predicate = [NSPredicate predicateWithFormat:@"identifier contains[cd] %@", identifier];
   
    if ([_resumeDownloadItems filteredArrayUsingPredicate:predicate].count > 0) {
        
        if (_currentActiveDownloadItems.count >= _currentDownloadMaximum) {
            
            // stop task frist and start new task.
            DownloaderItem* currentActiveTask = [_currentActiveDownloadItems getFristObject];
            currentActiveTask.downloadItemStatus =  DownloadItemStatusPaused;
            [currentActiveTask.downloadTask suspend];
            [_delegate multiDownloadItem:currentActiveTask downloadStatus:DownloadItemStatusPaused];
            [_currentActiveDownloadItems removeObjectForkey:currentActiveTask.identifier];
            
            // add into resumeList
            [_resumeDownloadItems addObject:currentActiveTask];
        }
        
        DownloaderItem* downloaderItem = [_resumeDownloadItems filteredArrayUsingPredicate:predicate][0];
        downloaderItem.downloadItemStatus = DownloadItemStatusStarted;
        [downloaderItem.downloadTask resume];
        [_delegate multiDownloadItem:downloaderItem downloadStatus:DownloadItemStatusStarted];
        
        [_currentActiveDownloadItems setObject:downloaderItem forKey:downloaderItem.identifier];
        [_resumeDownloadItems removeObject:downloaderItem];
    }
}

#pragma mark - cancelDownloadWithItemID

- (void)cancelDownloadWithItemID:(NSString *)identifier {
    
    DownloaderItem* downloaderItem = [_currentActiveDownloadItems getObjectForKey:identifier];
    
    if (downloaderItem) {
        
        // cancel activeList
        [_currentActiveDownloadItems removeObjectForkey:identifier];
       
        if (_pendingDownloadItems.count > 0) {
            
            DownloaderItem* nextdDownloaderItem = [_pendingDownloadItems objectAtIndex:0];
            
            nextdDownloaderItem.downloadItemStatus = DownloadItemStatusStarted;
            [nextdDownloaderItem.downloadTask resume];
            
            [_currentActiveDownloadItems setObject:nextdDownloaderItem forKey:nextdDownloaderItem.identifier];
            [_pendingDownloadItems removeObject:nextdDownloaderItem];
        }
        
        downloaderItem.downloadItemStatus = DownloadItemStatusCancelled;
        [downloaderItem.downloadTask cancel];
        [_delegate multiDownloadItem:downloaderItem downloadStatus:DownloadItemStatusCancelled];
        
    } else {
        
        NSPredicate* predicate = [NSPredicate predicateWithFormat:@"identifier contains[cd] %@", identifier];
        
        if ([_pendingDownloadItems filteredArrayUsingPredicate:predicate].count > 0) {
            
            // cancel pendingList
            downloaderItem = [_pendingDownloadItems filteredArrayUsingPredicate:predicate][0];
            [downloaderItem.downloadTask cancel];
            [_pendingDownloadItems removeObject:downloaderItem];
            [_delegate multiDownloadItem:downloaderItem downloadStatus:DownloadItemStatusCancelled];
        } else {
            
            NSPredicate* predicate = [NSPredicate predicateWithFormat:@"identifier contains[cd] %@", identifier];
            
            // cancel resumeList
            if ([_resumeDownloadItems filteredArrayUsingPredicate:predicate].count > 0) {
                
                downloaderItem = [_resumeDownloadItems filteredArrayUsingPredicate:predicate][0];
                [downloaderItem.downloadTask cancel];
                [_resumeDownloadItems removeObject:downloaderItem];
                [_delegate multiDownloadItem:downloaderItem downloadStatus:DownloadItemStatusCancelled];
            }
        }
    }
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

#pragma mark - cachesDirectoryUrlPath

- (NSURL *)cachesDirectoryUrlPath {
    
    NSArray* paths = NSSearchPathForDirectoriesInDomains(NSCachesDirectory, NSUserDomainMask, YES);
    NSString* cachesDirectory = [paths objectAtIndex:0];
    NSURL* cachesDirectoryUrl = [NSURL fileURLWithPath:cachesDirectory];
    
    return cachesDirectoryUrl;
}

@end
