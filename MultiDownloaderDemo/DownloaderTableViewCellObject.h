//
//  DownloaderTableViewCellObject.h
//  MultiDownloaderDemo
//
//  Created by Doan Van Vu on 9/5/17.
//  Copyright © 2017 Doan Van Vu. All rights reserved.
//

#import "MultiDownloaderCellActionDelegate.h"
#import <Foundation/Foundation.h>
#import "DownloaderItemStatus.h"
#import "NICellCatalog.h"
#import <UIKit/UIKit.h>

@protocol DownloaderTableViewCellObjectProtocol <NSObject>

@property (nonatomic) id<MultiDownloaderCellActionDelegate> delegate;
@property (readonly, nonatomic, copy) NSString* identifier;
@property (readonly, nonatomic, copy) NSString* taskDetail;
@property (readonly, nonatomic, copy) NSString* taskName;
@property (nonatomic) DownloaderItemStatus taskStatus;
@property (readonly, nonatomic, copy) NSURL* taskUrl;
@property (readonly, nonatomic) CGFloat process;

@end

@interface DownloaderTableViewCellObject : NITitleCellObject <DownloaderTableViewCellObjectProtocol>

@property (nonatomic) id<MultiDownloaderCellActionDelegate> delegate;
@property (nonatomic) DownloaderItemStatus taskStatus;
@property (nonatomic, copy) NSString* identifier;
@property (nonatomic, copy) NSString* taskDetail;
@property (nonatomic, copy) NSString* taskName;
@property (nonatomic, copy) NSURL* taskUrl;
@property (nonatomic) CGFloat process;

@end
