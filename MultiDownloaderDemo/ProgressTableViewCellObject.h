//
//  ProgressTableViewCellObject.h
//  NetWorking
//
//  Created by Doan Van Vu on 8/24/17.
//  Copyright © 2017 Doan Van Vu. All rights reserved.
//

#import "MultiDownloadCellActionDelegate.h"
#import <Foundation/Foundation.h>
#import "DownloaderItemStatus.h"
#import "NICellCatalog.h"
#import <UIKit/UIKit.h>

@protocol ProgressTableViewCellObjectProtocol <NSObject>

@property (nonatomic) id<MultiDownloadCellActionDelegate> delegate;
@property (readonly, nonatomic, copy) NSString* identifier;
@property (readonly, nonatomic, copy) NSString* taskDetail;
@property (readonly, nonatomic, copy) NSString* taskName;
@property (nonatomic) DownloaderItemStatus taskStatus;
@property (readonly, nonatomic, copy) NSURL* taskUrl;
@property (readonly, nonatomic) CGFloat process;

@end

@interface ProgressTableViewCellObject : NITitleCellObject <ProgressTableViewCellObjectProtocol>

@property (nonatomic) id<MultiDownloadCellActionDelegate> delegate;
@property (nonatomic) DownloaderItemStatus taskStatus;
@property (nonatomic, copy) NSString* identifier;
@property (nonatomic, copy) NSString* taskDetail;
@property (nonatomic, copy) NSString* taskName;
@property (nonatomic, copy) NSURL* taskUrl;
@property (nonatomic) CGFloat process;

@end
