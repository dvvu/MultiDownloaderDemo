//
//  MultiDownloaderViewController.m
//  MultiDownloaderDemo
//
//  Created by Doan Van Vu on 8/25/17.
//  Copyright © 2017 Doan Van Vu. All rights reserved.
//

#import <SystemConfiguration/SystemConfiguration.h>
#import "MultiDownloaderViewController.h"
#import "DownloaderTableViewCellObject.h"
#import "ThreadSafeForMutableArray.h"
#import "MultiDownloaderItemDelegate.h"
#import "NIMutableTableViewModel.h"
#import "MultiDownloaderManager.h"
#import "DownloaderTableViewCell.h"
#import "DownloaderItemStatus.h"
#import "ViewController.h"
#import "Masonry.h"

@interface MultiDownloaderViewController () <MultiDownloaderItemDelegate, NITableViewModelDelegate, MultiDownloaderCellActionDelegate, UITableViewDelegate>

@property (weak, nonatomic) IBOutlet UIBarButtonItem* connectionStatusButton;
@property (nonatomic) dispatch_queue_t multiDownloadItemsQueue;
@property (nonatomic) MultiDownloaderManager* downloadTasks;
@property (nonatomic) NSMutableArray* validDownloadLinks;
@property (nonatomic) ConnectionType connectionType;
@property (nonatomic) int maxCurrentDownloadTasks;
@property (nonatomic) NSDictionary* cellObjects;
@property (nonatomic) NITableViewModel* model;
@property (nonatomic) UITableView* tableView;
@property (nonatomic) NSArray* downloadLinks;

@end

@implementation MultiDownloaderViewController

- (void)viewDidLoad {
    
    [super viewDidLoad];
    [self connection];
    
    _tableView = [[UITableView alloc]init];
    _tableView.delegate = self;
    _tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
    _multiDownloadItemsQueue = dispatch_queue_create("MULTIDOWNLOADITEMS_QUEUE", DISPATCH_QUEUE_SERIAL);
    [_tableView setBackgroundColor:[UIColor colorWithRed:48/255.f green:22/255.f blue:49/255.f alpha:1.0f]];
    [self.view addSubview:_tableView];
    
    [_tableView mas_makeConstraints:^(MASConstraintMaker* make) {
        
        make.top.equalTo(self.view).offset(0);
        make.left.equalTo(self.view).offset(0);
        make.bottom.equalTo(self.view).offset(0);
        make.right.equalTo(self.view).offset(0);
    }];
    
    
    [self setupData];
}

#pragma mark - connection

- (void)connection {
    
    _connectionType = [MultiDownloaderViewController checkConnectionNetWork];
    
    switch (_connectionType) {
            
        case ConnectionTypeUnknown:
            
            break;
        case ConnectionType3G:
            
            _maxCurrentDownloadTasks = 1;
            [_connectionStatusButton setTitle:@"3G"];
            break;
        case ConnectionTypeWiFi:
            
            _maxCurrentDownloadTasks = 2;
            [_connectionStatusButton setTitle:@"WIFI"];
            break;
        case ConnectionTypeNone:
            
            _maxCurrentDownloadTasks = 0;
            [_connectionStatusButton setTitle:@"DISCONNECT"];
            [ViewController showConnectInternetAlert:self withTitle:@"DISCONNECTED" andMessage:@"Please check The internet and try again!"];
            break;
        default:
            break;
    }
}

#pragma mark - setupData

- (void)setupData {
    
    dispatch_async(_multiDownloadItemsQueue, ^ {
        
        _downloadLinks = @[FILE_URL,FILE_URL1,FILE_URL2,FILE_URL3,FILE_URL4,FILE_URL5,FILE_URL6,FILE_URL7];
        _validDownloadLinks = [NSMutableArray array];
        _downloadTasks = [[MultiDownloaderManager sharedManager] initBackgroundDownloadWithId:@"com.vn.vng.zalo.download" currentDownloadMaximum:_maxCurrentDownloadTasks delegate:self delegateQueue:[NSOperationQueue mainQueue]];
        
        NSMutableArray* objects = [NSMutableArray array];
        NSMutableDictionary* objectsDict = [[NSMutableDictionary alloc] init];
        
        for (int i = 0; i < _downloadLinks.count; i++) {
            
            DownloaderTableViewCellObject* cellObject = [[DownloaderTableViewCellObject alloc] init];
            NSURL* url = [NSURL URLWithString:_downloadLinks[i]];
            cellObject.taskName = [url lastPathComponent];
            cellObject.taskUrl = url;
            cellObject.identifier = @"";
            cellObject.taskStatus = DownloadItemStatusNotStarted;
            cellObject.delegate = self;
            
            if ([_downloadTasks fileExistsForUrl:url]) {
                
                cellObject.taskStatus = DownloadItemStatusCompleted;
            }
            
            if (_connectionType == ConnectionTypeNone) {
                
                cellObject.taskStatus = DownloadItemStatusInterrupted;
            }
            
            NSPredicate* predicate = [NSPredicate predicateWithFormat:@"SELF CONTAINS[cd] %@", _downloadLinks[i]];
            
            if ([_validDownloadLinks filteredArrayUsingPredicate:predicate].count > 0) {
                
                cellObject.taskStatus = DownloadItemStatusExisted;
                cellObject.taskUrl = [NSURL URLWithString:@""];
            } else {
                
                [_validDownloadLinks addObject:_downloadLinks[i]];
            }

            [objects addObject:cellObject];
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
    
    return 140;
}

#pragma mark - tableViewDelegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    
    [UIView animateWithDuration:0.05 animations: ^ {
        
        [tableView deselectRowAtIndexPath:indexPath animated:YES];
    }];
}

#pragma mark - startDownloadFromURL

- (void)startDownloadFromURL:(NSURL *)sourceURL {
    
    DownloaderTableViewCellObject* cellObject = _cellObjects[sourceURL];
    cellObject.identifier = [_downloadTasks startDownloadFromURL:sourceURL];
    cellObject.taskStatus = DownloadItemStatusPending;
    NSIndexPath* indexPath = [_model indexPathForObject:cellObject];
    DownloaderTableViewCell* cell = [_tableView cellForRowAtIndexPath:indexPath];
    
    dispatch_async(dispatch_get_main_queue(), ^ {
        
        [cell setModel:cellObject];
    });
}

#pragma mark - pauseDownloadWithItemID

- (void)pauseDownloadWithItemID:(NSString *)identifier {
    
    [_downloadTasks pauseDownloadWithItemID:identifier];
}

#pragma mark - resumeDownloadWithItemID

- (void)resumeDownloadWithItemID:(NSString *)identifier {
    
    [_downloadTasks resumeDownloadWithItemID:identifier];
}

#pragma mark - cancelDownloadWithItemID

- (void)cancelDownloadWithItemID:(NSString *)identifier {
    
    [_downloadTasks cancelDownloadWithItemID:identifier];
}

#pragma mark - MultiDownloadItem

- (void)multiDownloaderItem:(DownloaderItem *)downloaderItem didWriteData:(int64_t)bytesWritten totalBytesWritten:(int64_t)totalBytesWritten totalBytesExpectedToWrite:(int64_t)totalBytesExpectedToWrite {
    
    CGFloat progress = (CGFloat)totalBytesWritten / (CGFloat)totalBytesExpectedToWrite;
    DownloaderTableViewCellObject* cellObject = _cellObjects[downloaderItem.sourceURL];
    
    NSIndexPath* indexPath = [_model indexPathForObject:cellObject];
    DownloaderTableViewCell* cell = [_tableView cellForRowAtIndexPath:indexPath];
   
    CGFloat second = [self remainingTimeForDownload:downloaderItem bytesTransferred:totalBytesWritten totalBytesExpectedToWrite:totalBytesExpectedToWrite];
    NSString* formatByteWritten = [NSByteCountFormatter stringFromByteCount:totalBytesWritten countStyle:NSByteCountFormatterCountStyleFile];
    NSString* formatBytesExpected = [NSByteCountFormatter stringFromByteCount:totalBytesExpectedToWrite countStyle:NSByteCountFormatterCountStyleFile];
    NSString* detailInfo = [NSString stringWithFormat:@"%.0f%% - %@ / %@ - About: %@", progress * 100, formatByteWritten, formatBytesExpected, [self timeFormatted:second]];
    
    cellObject.process = progress;
    cellObject.taskStatus = downloaderItem.downloadItemStatus;
    cellObject.taskDetail = detailInfo;
    dispatch_async(dispatch_get_main_queue(), ^ {
        
        [cell setModel:cellObject];
    });
}

#pragma mark - MultiDownloadItem

- (void)multiDownloaderItem:(DownloaderItem *)downloaderItem didFinishDownloadFromURL:(NSURL *)destURL withError:(NSError *)error {
   
    DownloaderTableViewCellObject* cellObject = _cellObjects[downloaderItem.sourceURL];
    NSIndexPath* indexPath = [_model indexPathForObject:cellObject];
    DownloaderTableViewCell* cell = [_tableView cellForRowAtIndexPath:indexPath];
    
    if (downloaderItem.downloadItemStatus == DownloadItemStatusCompleted) {
        
        cellObject.process = 0.0;
        cellObject.taskDetail = @"";
        cellObject.taskStatus = DownloadItemStatusCompleted;
        dispatch_async(dispatch_get_main_queue(), ^ {
            
            [cell setModel:cellObject];
        });
    }
}

#pragma mark - MultiDownloadItem

- (void)multiDownloaderItem:(DownloaderItem *)downloaderItem downloadStatus:(DownloaderItemStatus)status {
    
    DownloaderTableViewCellObject* cellObject = _cellObjects[downloaderItem.sourceURL];
    NSIndexPath* indexPath = [_model indexPathForObject:cellObject];
    DownloaderTableViewCell* cell = [_tableView cellForRowAtIndexPath:indexPath];
    
    if (status == DownloadItemStatusPaused) {

        cellObject.taskStatus = DownloadItemStatusPaused;
        dispatch_async(dispatch_get_main_queue(), ^ {
            
            [cell setModel:cellObject];
        });
    } else if (status == DownloadItemStatusExisted) {
        
        NSLog(@"File is Downloaded");
    } else if (status == DownloadItemStatusNotStarted) {
        
        cellObject.taskStatus = DownloadItemStatusNotStarted;
        dispatch_async(dispatch_get_main_queue(), ^ {
            
            [cell setModel:cellObject];
        });
    } else if (status == DownloadItemStatusCancelled) {
        
        cellObject.process = 0.0;
        cellObject.taskStatus = DownloadItemStatusCancelled;
        cellObject.taskDetail = @"";
        dispatch_async(dispatch_get_main_queue(), ^ {
            
            [cell setModel:cellObject];
        });
    } else if (status == DownloadItemStatusStarted) {
        
        cellObject.taskStatus = DownloadItemStatusStarted;
        dispatch_async(dispatch_get_main_queue(), ^ {
            
            [cell setModel:cellObject];
        });
    } else if (status == DownloadItemStatusTimeOut) {
        
        cellObject.taskStatus = DownloadItemStatusTimeOut;
        cellObject.taskDetail = @"";
        dispatch_async(dispatch_get_main_queue(), ^ {
            
            [cell setModel:cellObject];
        });
    } else if (status == DownloadItemStatusInterrupted) {
        
        cellObject.taskStatus = DownloadItemStatusInterrupted;
        cellObject.taskDetail = @"";
        dispatch_async(dispatch_get_main_queue(), ^ {
            
            [cell setModel:cellObject];
        });
    }
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

#pragma mark - checkConnectionNetWork

+ (ConnectionType)checkConnectionNetWork {
    
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

@end
