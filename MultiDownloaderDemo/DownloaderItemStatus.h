//
//  DownloaderItemStatus.h
//  MultiDownloaderDemo
//
//  Created by Doan Van Vu on 8/25/17.
//  Copyright © 2017 Doan Van Vu. All rights reserved.
//

#define FILE_URL  @"http://ovh.net/files/10Mio.dat"
#define FILE_URL1 @"http://cdn.tutsplus.com/mobile/uploads/2013/12/sample.jpg"
#define FILE_URL2 @"http://spaceflight.nasa.gov/gallery/images/apollo/apollo17/hires/s72-55482.jpg"
#define FILE_URL3 @"http://spaceflight.nasa.gov/gallery/images/apollo/apollo10/hires/as10-34-5162.jpg"
#define FILE_URL4 @"http://spaceflight.nasa.gov/gallery/images/apollo-soyuz/apollo-soyuz/hires/s75-33375.jpg"
#define FILE_URL5 @"http://spaceflight.nasa.gov/gallery/images/apollo/apollo17/hires/as17-134-20380.jpg"
#define FILE_URL6 @"http://cdn.tutsplus.com/mobile/uploads/2013/12/sample.jpg"

//    if UIScreen.mainScreen().bounds.size.height == 480 {
//        // iPhone 4 height == 480
//        label.font = label.font.fontWithSize(20)
//    } else if UIScreen.mainScreen().bounds.size.height == 568 {
//        // IPhone 5 height == 568
//        label.font = label.font.fontWithSize(20)
//    } else if UIScreen.mainScreen().bounds.size.width == 375 {
//        // iPhone 6 width == 375
//        label.font = label.font.fontWithSize(20)
//    } else if UIScreen.mainScreen().bounds.size.width == 414 {
//        // iPhone 6+ width == 414
//        label.font = label.font.fontWithSize(20)
//    } else if UIScreen.mainScreen().bounds.size.width == 768 {
//        // iPad
//        label.font = label.font.fontWithSize(20)
//    }

#define FONTSIZE_SCALE [[UIScreen mainScreen] bounds].size.height == 480 ? 1 : ([[UIScreen mainScreen] bounds].size.height == 568 ? 1.12 : ([[UIScreen mainScreen] bounds].size.width == 375 ? 1.21 : ([[UIScreen mainScreen] bounds].size.width == 414 ? 1.23 : 1.23)))

#pragma mark - DownloaderItemStatus

typedef NS_ENUM(NSUInteger, DownloaderItemStatus) {
    
    DownloadItemStatusNotStarted = 0,
    DownloadItemStatusStarted,
    DownloadItemStatusCompleted,
    DownloadItemStatusPaused,
    DownloadItemStatusCancelled,
    DownloadItemStatusInterrupted,
    DownloadItemStatusExisted,
    DownloadItemStatusPending,
    DownloadItemStatusError
};

#pragma mark - DownloadButtonStatus

typedef NS_ENUM(NSUInteger, DownloadButtonStatus) {
    
    DownloadButtonStatusDownload,
    DownloadButtonStatusPlay,
    DownloadButtonStatusPause,
};

typedef NS_ENUM(NSUInteger, ConnectionType) {
    
    ConnectionTypeUnknown,
    ConnectionTypeNone,
    ConnectionType3G,
    ConnectionTypeWiFi
};
