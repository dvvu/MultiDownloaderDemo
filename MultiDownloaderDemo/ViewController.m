//
//  ViewController.m
//  MultiDownloaderDemo
//
//  Created by Doan Van Vu on 8/24/17.
//  Copyright © 2017 Doan Van Vu. All rights reserved.
//

#import "MultiDownloadManager.h"
#import "ViewController.h"

#define FILE_URL  @"http://ovh.net/files/10Mio.dat"
#define FILE_URL1 @"http://spaceflight.nasa.gov/gallery/images/apollo/apollo10/hires/as10-34-5162.jpg"

@interface ViewController () <MultiDownloadItemDelegate>

@property (weak, nonatomic) IBOutlet UILabel *status1;
@property (weak, nonatomic) IBOutlet UILabel *info1;
@property (weak, nonatomic) IBOutlet UIProgressView *v1;
@property (weak, nonatomic) IBOutlet UILabel *status2;
@property (weak, nonatomic) IBOutlet UILabel *info2;
@property (weak, nonatomic) IBOutlet UIProgressView *v2;

@property (strong, nonatomic) MultiDownloadManager *downloadTasks;
@property (strong, nonatomic) NSURL* url;
@property (strong, nonatomic) NSURL* url1;
@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    _url = [NSURL URLWithString:FILE_URL];
    _url1 = [NSURL URLWithString:FILE_URL1];
//    _downloadTasks = [[MultiDownloadManager sharedManager] initDefaultDownloadWithDelegate:self delegateQueue:[NSOperationQueue mainQueue]];
    _downloadTasks = [[MultiDownloadManager sharedManager] initBackgroundDownloadWithId:@"com.vn.vng.zalo.download" currentDownloadMaximum:2 delegate:self delegateQueue:[NSOperationQueue mainQueue]];
}

- (IBAction)start1:(id)sender {

    [_downloadTasks startDownloadFromURL:_url];
}
- (IBAction)pause1:(id)sender {
    
    [_downloadTasks pauseDownloadFromURL:_url];
}
- (IBAction)resume1:(id)sender {
    
    [_downloadTasks resumeDownloadFromURL:_url];
}
- (IBAction)cancel1:(id)sender {
    
    [_downloadTasks cancelDownloadFromURL:_url];
}
- (IBAction)start2:(id)sender {
    
   
    [_downloadTasks startDownloadFromURL:_url1];
}
- (IBAction)pause2:(id)sender {
    
    [_downloadTasks pauseDownloadFromURL:_url1];
}
- (IBAction)resume2:(id)sender {
    
    [_downloadTasks resumeDownloadFromURL:_url1];
}
- (IBAction)cancel2:(id)sender {
    
    [_downloadTasks cancelDownloadFromURL:_url1];
}
- (IBAction)resumeAll:(id)sender {
    
}
- (IBAction)pauseAll:(id)sender {
    
}

#pragma mark - MultiDownloadItem

- (void)multiDownloadItem:(DownloaderItem *)downloaderItem with:(NSURL *)url didWriteData:(int64_t)bytesWritten totalBytesWritten:(int64_t)totalBytesWritten totalBytesExpectedToWrite:(int64_t)totalBytesExpectedToWrite {

    CGFloat progress = (CGFloat)totalBytesWritten / (CGFloat)totalBytesExpectedToWrite;
    NSString* result = [NSString stringWithFormat:@"%.0f%%  ", progress * 100];
    
    if([[url absoluteString] isEqualToString:[_url absoluteString]]) {
        
        _info1.text = result;
    } else {
        _info2.text = result;
    }
    
    NSLog(@"1 %lu",(unsigned long)downloaderItem.downloadItemStatus);
}

#pragma mark - MultiDownloadItem
- (void)multiDownloadItem:(DownloaderItem *)downloaderItem didFinishDownloadFromURL:(NSURL *)sourceUrl toURL:(NSURL *)destUrl withError:(NSError *)error {
    
    NSLog(@"2 %@",error);
    NSLog(@"ERROR %lu",(unsigned long)downloaderItem.downloadItemStatus);
    if(sourceUrl == _url1) {
        
    } else {
        
    }
}

#pragma mark - MultiDownloadItem
- (void)multiDownloadItem:(DownloaderItem *)downloaderItem internetDisconnectFromURL:(NSURL *)url {
    
    NSLog(@"3 %lu",(unsigned long)downloaderItem.downloadItemStatus);
    NSLog(@"internetDisconnectFromURL %@",url);
    
}

#pragma mark - MultiDownloadItem
- (void)multiDownloadItem:(DownloaderItem *)downloaderItem connectionTimeOutFromURL:(NSURL *)url {
    
    NSLog(@"4 %lu",(unsigned long)downloaderItem.downloadItemStatus);
    NSLog(@"connectionTimeOutFromURL %@",url);
}

#pragma mark - remainingTimeForDownload

- (CGFloat)remainingTimeForDownload:(DownloaderItem *)downloaderItem bytesTransferred:(int64_t)bytesTransferred totalBytesExpectedToWrite:(int64_t)totalBytesExpectedToWrite {
    
    NSTimeInterval timeInterval = [[NSDate date] timeIntervalSinceDate:downloaderItem.startDate];
    CGFloat speed = (CGFloat)bytesTransferred / (CGFloat)timeInterval;
    CGFloat remainingBytes = totalBytesExpectedToWrite - bytesTransferred;
    CGFloat remainingTime = remainingBytes / speed;
    
    return remainingTime;
}

@end
