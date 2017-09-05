//
//  DownloaderTableViewCell.h
//  MultiDownloaderDemo
//
//  Created by Doan Van Vu on 9/5/17.
//  Copyright © 2017 Doan Van Vu. All rights reserved.
//

#import "MultiDownloaderCellActionDelegate.h"
#import "DownloaderTableViewCellObject.h"
#import "NICellCatalog.h"
#import <UIKit/UIKit.h>

#pragma mark - DownloadButtonStatus

@interface DownloaderTableViewCell : UITableViewCell <NICell>

@property (nonatomic) id<DownloaderTableViewCellObjectProtocol> model;
@property (nonatomic) id<MultiDownloaderCellActionDelegate> delegate;
@property (nonatomic) UIProgressView* progressView;
@property (nonatomic) UIButton* downloadButton;
@property (nonatomic) UILabel* taskStatusLabel;
@property (nonatomic) UILabel* taskDetailLabel;
@property (nonatomic) UIButton* cancelButton;
@property (nonatomic) UILabel* taskNameLabel;
@property (nonatomic) UILabel* taskLinkLabel;
@property (nonatomic) NSString* identifier;
@property (nonatomic) NSURL* link;

@end
