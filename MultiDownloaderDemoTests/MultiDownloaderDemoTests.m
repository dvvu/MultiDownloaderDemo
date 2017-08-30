//
//  MultiDownloaderDemoTests.m
//  MultiDownloaderDemoTests
//
//  Created by Doan Van Vu on 8/24/17.
//  Copyright © 2017 Doan Van Vu. All rights reserved.
//

#import <XCTest/XCTest.h>
#import "MultiDownloadManager.h"

@interface MultiDownloaderDemoTests : XCTestCase

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
    
    MultiDownloadManager* downloadTasks = [[MultiDownloadManager sharedManager] initBackgroundDownloadWithId:@"com.vn.vng.zalo.download" currentDownloadMaximum:1 delegate:self delegateQueue:[NSOperationQueue mainQueue]];
    
    NSURL* url = [NSURL URLWithString:@"http://spaceflight.nasa.gov/gallery/images/apollo/apollo17/hires/s72-55482.jpg"];
    
    for(int i = 0; i < 100; i++) {
        
        [downloadTasks startDownloadFromURL:url];
    }
}

- (void)testPerformanceExample {
    // This is an example of a performance test case.
    [self measureBlock:^{
        // Put the code you want to measure the time of here.
    }];
}

@end
