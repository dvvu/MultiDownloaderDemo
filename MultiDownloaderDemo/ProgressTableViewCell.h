//
//  ProgressTableViewCell.h
//  MultiDownloaderDemo
//
//  Created by Doan Van Vu on 8/25/17.
//  Copyright © 2017 Doan Van Vu. All rights reserved.
//

#import "MultiDownloadCellActionDelegate.h"
#import "ProgressTableViewCellObject.h"
#import "NICellCatalog.h"
#import <UIKit/UIKit.h>

#pragma mark - DownloadButtonStatus

@interface ProgressTableViewCell : UITableViewCell <NICell>

@property (nonatomic) id<ProgressTableViewCellObjectProtocol> model;
@property (nonatomic) id<MultiDownloadCellActionDelegate> delegate;
@property (nonatomic) UIProgressView* progressView;
@property (nonatomic) UIButton* downloadButton;
@property (nonatomic) UILabel* taskStatusLabel;
@property (nonatomic) UILabel* taskDetailLabel;
@property (nonatomic) UIButton* cancelButton;
@property (nonatomic) UILabel* taskNameLabel;
@property (nonatomic) UILabel* taskLinkLabel;
@property (nonatomic) NSURL* link;

- (void)updateProgress:(CGFloat)progress withInfo:(NSString *)detail;
- (void)statusDownloader:(DownloaderItemStatus)status;
@end
