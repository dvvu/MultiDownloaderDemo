//
//  MultiDownloaderViewController.m
//  MultiDownloaderDemo
//
//  Created by Doan Van Vu on 8/25/17.
//  Copyright © 2017 Doan Van Vu. All rights reserved.
//

#import <SystemConfiguration/SystemConfiguration.h>
#import "MultiDownloaderViewController.h"
#import "ProgressTableViewCellObject.h"
#import "ThreadSafeForMutableArray.h"
#import "MultiDownloadItemDelegate.h"
#import "NIMutableTableViewModel.h"
#import "MultiDownloadManager.h"
#import "ProgressTableViewCell.h"
#import "DownloaderItemStatus.h"
#import "Masonry.h"

@interface MultiDownloaderViewController () <MultiDownloadItemDelegate, NITableViewModelDelegate, MultiDownloadCellActionDelegate, UITableViewDelegate>

@property (nonatomic) dispatch_queue_t multiDownloadItemsQueue;
@property (nonatomic) ThreadSafeForMutableArray* canDownLinks;
@property (nonatomic) MultiDownloadManager* downloadTasks;
@property (nonatomic) NSMutableArray* validDownloadLinks;
@property (nonatomic) NSDictionary* cellObjects;
@property (nonatomic) NITableViewModel* model;
@property (nonatomic) UITableView* tableView;
@property (nonatomic) NSArray* downloadLinks;
@property (nonatomic) BOOL isEnableMaxDownload;

@end

@implementation MultiDownloaderViewController

- (void)viewDidLoad {
    
    [super viewDidLoad];
    
    _tableView = [[UITableView alloc]init];
    _tableView.delegate = self;
    _multiDownloadItemsQueue = dispatch_queue_create("MultiDownloadItems_QUEUE", DISPATCH_QUEUE_SERIAL);
    [self.view addSubview:_tableView];

    [_tableView mas_makeConstraints:^(MASConstraintMaker* make) {
        
        make.top.equalTo(self.view).offset(0);
        make.left.equalTo(self.view).offset(0);
        make.bottom.equalTo(self.view).offset(0);
        make.right.equalTo(self.view).offset(0);
    }];
    
    [self setupData];
    [MultiDownloaderViewController connectionType];
}

+ (ConnectionType)connectionType {
    
    SCNetworkReachabilityRef reachability = SCNetworkReachabilityCreateWithName(NULL, "8.8.8.8");
    SCNetworkReachabilityFlags flags;
    BOOL success = SCNetworkReachabilityGetFlags(reachability, &flags);
    CFRelease(reachability);
    
    if (!success) {
    
        return ConnectionTypeUnknown;
    }
    
    BOOL isReachable = ((flags & kSCNetworkReachabilityFlagsReachable) != 0);
    BOOL needsConnection = ((flags & kSCNetworkReachabilityFlagsConnectionRequired) != 0);
    BOOL isNetworkReachable = (isReachable && !needsConnection);
    
    if (!isNetworkReachable) {
      
        return ConnectionTypeNone;
    } else if ((flags & kSCNetworkReachabilityFlagsIsWWAN) != 0) {
      
        return ConnectionType3G;
    } else {
        
        return ConnectionTypeWiFi;
    }
}

#pragma mark - setupData

- (void)setupData {
    
    dispatch_async(_multiDownloadItemsQueue, ^ {
        
        _downloadLinks = @[FILE_URL,FILE_URL1,FILE_URL2,FILE_URL3,FILE_URL4,FILE_URL5,FILE_URL6];
        _canDownLinks = [[ThreadSafeForMutableArray alloc] init];
        _validDownloadLinks = [NSMutableArray array];
        _downloadTasks = [[MultiDownloadManager sharedManager] initBackgroundDownloadWithId:@"com.vn.vng.zalo.download" currentDownloadMaximum:MAX_CURRENTDOWNLOAD delegate:self delegateQueue:[NSOperationQueue mainQueue]];
        
        NSMutableArray* objects = [NSMutableArray array];
        NSMutableDictionary* objectsDict = [[NSMutableDictionary alloc] init];
        
        for (int i = 0; i < _downloadLinks.count; i++) {
            
            ProgressTableViewCellObject* cellObject = [[ProgressTableViewCellObject alloc] init];
            NSURL* url = [NSURL URLWithString:_downloadLinks[i]];
            cellObject.taskName = [url lastPathComponent];
            cellObject.taskUrl = url;
            cellObject.taskStatus = DownloadItemStatusNotStarted;
            cellObject.delegate = self;
            
            if ([_downloadTasks fileExistsForUrl:url]) {
                
                cellObject.taskStatus = DownloadItemStatusCompleted;
            }
            
            NSPredicate* predicate = [NSPredicate predicateWithFormat:@"SELF CONTAINS[cd] %@", _downloadLinks[i]];
            
            if([_validDownloadLinks filteredArrayUsingPredicate:predicate].count > 0) {
                
                cellObject.taskStatus = DownloadItemStatusExisted;
                cellObject.taskUrl = [NSURL URLWithString:@"http://downloadTheSameURL"];
            } else {
                
                [_validDownloadLinks addObject:_downloadLinks[i]];
            }

            [objects addObject:cellObject];
            
            if (cellObject.taskStatus == DownloadItemStatusNotStarted) {
                
                [_canDownLinks addObject:url];
            }
            objectsDict[cellObject.taskUrl] = cellObject;
        }
        
        _model = [[NITableViewModel alloc] initWithListArray:objects delegate:self];
        _tableView.dataSource = _model;
        _cellObjects = objectsDict;
        
        dispatch_async(dispatch_get_main_queue(), ^ {
            
            [_tableView reloadData];
        });
    });
}

#pragma mark - NITableViewModelDelegate

- (UITableViewCell *)tableViewModel:(NITableViewModel *)tableViewModel cellForTableView:(UITableView *)tableView atIndexPath:(NSIndexPath *)indexPath withObject:(id)object {
    
    return [NICellFactory tableViewModel:tableViewModel cellForTableView:tableView atIndexPath:indexPath withObject:object];
}

#pragma mark - tableViewDelegate

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    return 100;
}

#pragma mark - startDownloadFromURL

- (void)startDownloadFromURL:(NSURL *)sourceURL {
    
    if (_isEnableMaxDownload) {
        
        //pause and move object to last.
        [_downloadTasks pauseDownloadFromURL:[_canDownLinks objectAtIndex:0]];
        [_canDownLinks removeObject:[_canDownLinks objectAtIndex:0]];
        [_canDownLinks addObject:[_canDownLinks objectAtIndex:0]];
    }
    
    [_downloadTasks startDownloadFromURL:sourceURL];
}

#pragma mark - pauseDownloadFromURL

- (void)pauseDownloadFromURL:(NSURL *)sourceURL {
    
    if (_isEnableMaxDownload) {
        
        //move object to last
        [_canDownLinks removeObject:sourceURL];
        [self downloadNextTask];
        [_canDownLinks addObject:sourceURL];
    }
    
    [_downloadTasks pauseDownloadFromURL:sourceURL];
}

#pragma mark - resumeDownloadFromURL

- (void)resumeDownloadFromURL:(NSURL *)sourceURL {
    
    if (_isEnableMaxDownload) {
        
        if ([sourceURL isEqual:[_canDownLinks objectAtIndex:0]]) {
            
            //pause and move object to last.
            [_downloadTasks pauseDownloadFromURL:[_canDownLinks objectAtIndex:1]];
            [_canDownLinks removeObject:[_canDownLinks objectAtIndex:1]];
            [_canDownLinks addObject:[_canDownLinks objectAtIndex:1]];
        } else {
            //pause and move object to last.
            [_downloadTasks pauseDownloadFromURL:[_canDownLinks objectAtIndex:0]];
            [_canDownLinks removeObject:[_canDownLinks objectAtIndex:0]];
            [_canDownLinks addObject:[_canDownLinks objectAtIndex:0]];
        }
    }
    
    [_downloadTasks resumeDownloadFromURL:sourceURL];
}

#pragma mark - cancelDownloadFromURL

- (void)cancelDownloadFromURL:(NSURL *)sourceURL {
    
    [_downloadTasks cancelDownloadFromURL:sourceURL];
}

#pragma mark - MultiDownloadItem

- (void)multiDownloadItem:(DownloaderItem *)downloaderItem with:(NSURL *)sourceURL didWriteData:(int64_t)bytesWritten totalBytesWritten:(int64_t)totalBytesWritten totalBytesExpectedToWrite:(int64_t)totalBytesExpectedToWrite {
    
    CGFloat progress = (CGFloat)totalBytesWritten / (CGFloat)totalBytesExpectedToWrite;
    ProgressTableViewCellObject* cellObject = _cellObjects[sourceURL];
    
    NSIndexPath* indexPath = [_model indexPathForObject:cellObject];
    ProgressTableViewCell* cell = [_tableView cellForRowAtIndexPath:indexPath];
   
    CGFloat second = [self remainingTimeForDownload:downloaderItem bytesTransferred:totalBytesWritten totalBytesExpectedToWrite:totalBytesExpectedToWrite];
    NSString* formatByteWritten = [NSByteCountFormatter stringFromByteCount:totalBytesWritten countStyle:NSByteCountFormatterCountStyleFile];
    NSString* formatBytesExpected = [NSByteCountFormatter stringFromByteCount:totalBytesExpectedToWrite countStyle:NSByteCountFormatterCountStyleFile];
    NSString* detailInfo = [NSString stringWithFormat:@"%.0f%% - %@ / %@ - About: %@", progress * 100, formatByteWritten, formatBytesExpected, [self timeFormatted:second]];
    
    cellObject.process = progress;
    cellObject.taskStatus = downloaderItem.downloadItemStatus;
    cellObject.taskDetail = detailInfo;
    [cell setModel:cellObject];
}

#pragma mark - MultiDownloadItem

- (void)multiDownloadItem:(DownloaderItem *)downloaderItem didFinishDownloadFromURL:(NSURL *)sourceURL toURL:(NSURL *)destURL withError:(NSError *)error {
   
    ProgressTableViewCellObject* cellObject = _cellObjects[sourceURL];
    NSIndexPath* indexPath = [_model indexPathForObject:cellObject];
    ProgressTableViewCell* cell = [_tableView cellForRowAtIndexPath:indexPath];
    
    if (downloaderItem.downloadItemStatus == DownloadItemStatusCancelled) {
        
        cellObject.process = 0.0;
        cellObject.taskStatus = DownloadItemStatusCancelled;
        cellObject.taskDetail = @"";
        [cell setModel:cellObject];
        
        //move object to last
        [_canDownLinks removeObject:sourceURL];
        [self downloadNextTask];
        [_canDownLinks addObject:sourceURL];
    } else if (downloaderItem.downloadItemStatus == DownloadItemStatusCompleted) {
        
        cellObject.process = 0.0;
        cellObject.taskDetail = @"";
        cellObject.taskStatus = DownloadItemStatusCompleted;
        [cell setModel:cellObject];
        
        [_canDownLinks removeObject:sourceURL];
        [self downloadNextTask];
    }
}

#pragma mark - downloadNextTask

- (void)downloadNextTask {
    
    if (_canDownLinks.count > 0) {

        // start next downloadTask
        if (_canDownLinks.count >= MAX_CURRENTDOWNLOAD) {
            
            // download max config by MAX_CURRENTDOWNLOAD
            [_downloadTasks startDownloadFromURL:[_canDownLinks objectAtIndex:MAX_CURRENTDOWNLOAD - 1]];
        }
    }
}

#pragma mark - MultiDownloadItem

- (void)multiDownloadItem:(DownloaderItem *)downloaderItem internetDisconnectFromURL:(NSURL *)sourceURL {
    
     NSLog(@"internetDisconnectFromURL");
}

#pragma mark - MultiDownloadItem

- (void)multiDownloadItem:(DownloaderItem *)downloaderItem connectionTimeOutFromURL:(NSURL *)sourceURL {
    
    NSLog(@"connectionTimeOutFromURL");
}

#pragma mark - MultiDownloadItem

- (void)multiDownloadItem:(NSURL *)sourceURL downloadStatus:(DownloaderItemStatus)status {
    
    if(status == DownloadItemStatusPaused) {
       
        ProgressTableViewCellObject* cellObject = _cellObjects[sourceURL];
        NSIndexPath* indexPath = [_model indexPathForObject:cellObject];
        ProgressTableViewCell* cell = [_tableView cellForRowAtIndexPath:indexPath];
        cellObject.taskStatus = DownloadItemStatusPaused;
        [cell setModel:cellObject];
    } else if (status == DownloadItemStatusExisted) {
        
        NSLog(@"File is Downloaded");
    }
}

#pragma mark - activeNextTaskDelegate

- (void)activeNextTaskDelegate {
    
}

#pragma mark - pauseFirstTaskDelegate

- (void)pauseFirstTaskDelegate {
    
}

#pragma mark - remainingTimeForDownload

- (CGFloat)remainingTimeForDownload:(DownloaderItem *)downloaderItem bytesTransferred:(int64_t)bytesTransferred totalBytesExpectedToWrite:(int64_t)totalBytesExpectedToWrite {
    
    NSTimeInterval timeInterval = [[NSDate date] timeIntervalSinceDate:downloaderItem.startDate];
    CGFloat speed = (CGFloat)bytesTransferred / (CGFloat)timeInterval;
    CGFloat remainingBytes = totalBytesExpectedToWrite - bytesTransferred;
    CGFloat remainingTime = remainingBytes / speed;
    
    return remainingTime;
}

#pragma mark - timeFormatted

- (NSString *)timeFormatted:(int)totalSeconds {
    
    int seconds = totalSeconds % 60;
    int minutes = (totalSeconds / 60) % 60;
    int hours = totalSeconds / 3600;
    
    if (hours) {
        
        return [NSString stringWithFormat:@"%02dh:%02dm:%02ds",hours, minutes, seconds];
    } else if (minutes) {
        
        return [NSString stringWithFormat:@"%02dm:%02ds", minutes, seconds];
    } else {
        
        return [NSString stringWithFormat:@"%02ds", seconds];
    }
}

#pragma mark - startMaxdownload

- (IBAction)startMaxdownload:(id)sender {
    
    if (_canDownLinks.count > MAX_CURRENTDOWNLOAD) {
        
        // download max config by MAX_CURRENTDOWNLOAD
        for (int i = 0; i < MAX_CURRENTDOWNLOAD; i++) {
            
            [_downloadTasks startDownloadFromURL:[_canDownLinks objectAtIndex:i]];
        }
    } else {
        
        // download all
        for (int i = 0; i < _canDownLinks.count; i++) {
        
            [_downloadTasks startDownloadFromURL:[_canDownLinks objectAtIndex:i]];
        }
    }
}

#pragma mark - enableDownloadNext

- (IBAction)enableDownloadNext:(id)sender {
    
    _isEnableMaxDownload = !_isEnableMaxDownload;
    
    NSLog(@"%d",_isEnableMaxDownload);
}

@end
