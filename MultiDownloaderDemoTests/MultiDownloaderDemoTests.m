//
//  MultiDownloaderDemoTests.m
//  MultiDownloaderDemoTests
//
//  Created by Doan Van Vu on 8/24/17.
//  Copyright © 2017 Doan Van Vu. All rights reserved.
//

#import <XCTest/XCTest.h>
#import "MultiDownloadManager.h"

@interface MultiDownloaderDemoTests : XCTestCase <MultiDownloadItemDelegate>

@end

@implementation MultiDownloaderDemoTests

- (void)setUp {
    [super setUp];
    // Put setup code here. This method is called before the invocation of each test method in the class.
}

- (void)tearDown {
    // Put teardown code here. This method is called after the invocation of each test method in the class.
    [super tearDown];
}

- (void)testExample {
    
    for(int i = 0; i < 100; i++) {
        
        NSURL* url = [NSURL URLWithString:@"http://ovh.net/files/10Mio.dat"];
        [[[MultiDownloadManager sharedManager] initDefaultDownloadWithDelegate:3 delegate:self delegateQueue:[NSOperationQueue mainQueue]] startDownloadFromURL:url];
    }
}

- (void)testPerformanceExample {
    // This is an example of a performance test case.
    [self measureBlock:^{
        // Put the code you want to measure the time of here.
    }];
}


- (void)multiDownloadItem:(DownloaderItem *)downloaderItem didWriteData:(int64_t)bytesWritten totalBytesWritten:(int64_t)totalBytesWritten totalBytesExpectedToWrite:(int64_t)totalBytesExpectedToWrite {
    
    CGFloat progress = (CGFloat)totalBytesWritten / (CGFloat)totalBytesExpectedToWrite;
    NSLog(@"%f", progress);
}

#pragma mark - MultiDownloadItem

- (void)multiDownloadItem:(DownloaderItem *)downloaderItem didFinishDownloadFromURL:(NSURL *)destURL withError:(NSError *)error {
    
    if (downloaderItem.downloadItemStatus == DownloadItemStatusCancelled) {
        
        NSLog(@"File is DownloadItemStatusCancelled");
        
    } else if (downloaderItem.downloadItemStatus == DownloadItemStatusCompleted) {
        
        NSLog(@"File is DownloadItemStatusCompleted");
    }
}

#pragma mark - MultiDownloadItem

- (void)multiDownloadItem:(DownloaderItem *)downloaderItem downloadStatus:(DownloaderItemStatus)status {
    
    if(status == DownloadItemStatusPaused) {
        
        NSLog(@"File is DownloadItemStatusPaused");
    } else if (status == DownloadItemStatusExisted) {
        
        NSLog(@"File is DownloadItemStatusExisted");
    } else if (status == DownloadItemStatusNotStarted) {
        
       NSLog(@"File is DownloadItemStatusNotStarted");
    }
}

@end
