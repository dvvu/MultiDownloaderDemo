//
//  MultiDownloaderViewController.m
//  MultiDownloaderDemo
//
//  Created by Doan Van Vu on 8/25/17.
//  Copyright © 2017 Doan Van Vu. All rights reserved.
//

#import "MultiDownloaderViewController.h"
#import "ProgressTableViewCellObject.h"
#import "MultiDownloadItemDelegate.h"
#import "NIMutableTableViewModel.h"
#import "MultiDownloadManager.h"
#import "ProgressTableViewCell.h"
#import "DownloaderItemStatus.h"
#import "Masonry.h"

@interface MultiDownloaderViewController () <MultiDownloadItemDelegate, NITableViewModelDelegate, MultiDownloadCellActionDelegate, UITableViewDelegate>

@property (nonatomic) MultiDownloadManager* downloadTasks;
@property (nonatomic) NITableViewModel* model;
@property (nonatomic) UITableView* tableView;
@property (nonatomic) NSArray* links;
@property (nonatomic) NSDictionary* cellObjects;
@end

@implementation MultiDownloaderViewController

- (void)viewDidLoad {
    
    [super viewDidLoad];
    
    _tableView = [[UITableView alloc]init];
    _tableView.delegate = self;
    [self.view addSubview:_tableView];

    [_tableView mas_makeConstraints:^(MASConstraintMaker* make) {
        
        make.top.equalTo(self.view).offset(0);
        make.left.equalTo(self.view).offset(0);
        make.bottom.equalTo(self.view).offset(0);
        make.right.equalTo(self.view).offset(0);
    }];
    
    [self setupData];
}

#pragma mark - setupData

- (void)setupData {
    
    _links = @[FILE_URL,FILE_URL1,FILE_URL2,FILE_URL3,FILE_URL4,FILE_URL5,FILE_URL6];
    _downloadTasks = [[MultiDownloadManager sharedManager] initBackgroundDownloadWithId:@"com.vn.vng.zalo.download" currentDownloadMaximum:2 delegate:self delegateQueue:[NSOperationQueue mainQueue]];
    NSMutableArray* objects = [NSMutableArray array];
    
    NSMutableDictionary* dict = [[NSMutableDictionary alloc] init];
    
    for (int i = 0; i < _links.count; i++) {
        
        ProgressTableViewCellObject* cellObject = [[ProgressTableViewCellObject alloc] init];
        NSURL* url = [NSURL URLWithString:_links[i]];
        cellObject.taskName = [url lastPathComponent];
        cellObject.taskUrl = url;
        cellObject.taskStatus = DownloadItemStatusNotStarted;
        cellObject.delegate = self;
        [objects addObject:cellObject];
      
        if ([_downloadTasks fileExistsForUrl:url]) {
            
            cellObject.taskStatus = DownloadItemStatusCompleted;
        }
        
        dict[cellObject.taskUrl] = cellObject;
    }
    
    _model = [[NITableViewModel alloc] initWithListArray:objects delegate:self];
    _tableView.dataSource = _model;
    _cellObjects = dict;
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
    
    [_downloadTasks startDownloadFromURL:sourceURL];
}

#pragma mark - pauseDownloadFromURL

- (void)pauseDownloadFromURL:(NSURL *)sourceURL {
    
    [_downloadTasks pauseDownloadFromURL:sourceURL];
}

#pragma mark - resumeDownloadFromURL

- (void)resumeDownloadFromURL:(NSURL *)sourceURL {
    
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
    NSString* detailInfo = [NSString stringWithFormat:@"%.0f%% - %@ / %@ - About: %@ s ", progress * 100, formatByteWritten, formatBytesExpected, [self timeFormatted:second]];
    
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
    } else if (downloaderItem.downloadItemStatus == DownloadItemStatusCompleted) {
        
        cellObject.process = 0.0;
        cellObject.taskDetail = @"";
        cellObject.taskStatus = DownloadItemStatusCompleted;
        [cell setModel:cellObject];
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
    
    return [NSString stringWithFormat:@"%02d:%02d:%02d",hours, minutes, seconds];
}

@end
