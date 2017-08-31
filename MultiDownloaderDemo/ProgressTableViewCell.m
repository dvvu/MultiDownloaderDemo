//
//  ProgressTableViewCell.m
//  MultiDownloaderDemo
//
//  Created by Doan Van Vu on 8/25/17.
//  Copyright © 2017 Doan Van Vu. All rights reserved.
//

#import "ProgressTableViewCellObject.h"
#import "ProgressTableViewCell.h"
#import "Masonry.h"

@interface ProgressTableViewCell ()

@property (nonatomic) DownloadButtonStatus downloadButtonStatus;
@property (nonatomic) UIView* progresssCellView;
@end

@implementation ProgressTableViewCell

#pragma mark - init TableCell

- (instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier {
    
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    
    if (self) {
        
        [self setupLayoutForCell];
    }
    
    return self;
}

#pragma mark - delegate oif NICell -> change when something is changed in cell

- (BOOL)shouldUpdateCellWithObject:(id<ProgressTableViewCellObjectProtocol>)object {
    
    ProgressTableViewCellObject* cellObject = (ProgressTableViewCellObject *)object;
    
    _link = cellObject.taskUrl;
    _delegate = cellObject.delegate;
    _taskNameLabel.text = cellObject.taskName;
    _progressView.progress = cellObject.process;
    _taskDetailLabel.text = cellObject.taskDetail;
    _taskLinkLabel.text = [cellObject.taskUrl absoluteString];
    _identifier = cellObject.identifier;
    [self statusDownloader: cellObject.taskStatus];

    return YES;
}

- (void)setModel:(id<ProgressTableViewCellObjectProtocol>)model {
  
    _model = model;
    _identifier = _model.identifier;
    [self updateProgress:_model.process withInfo:_model.taskDetail];
}

#pragma mark - updateProcess

- (void)updateProgress:(CGFloat)progress withInfo:(NSString *)detail {

    _progressView.progress = progress;
    _taskDetailLabel.text = detail;
    [self statusDownloader:_model.taskStatus];
}

#pragma mark - statusDownloader

- (void)statusDownloader:(DownloaderItemStatus)status {
    
    switch (status) {
            
        case DownloadItemStatusNotStarted:
            
            [_downloadButton setEnabled:YES];
            [_cancelButton setEnabled:NO];
            [_downloadButton setHidden:NO];
            [_cancelButton setHidden:NO];
            [_progressView setHidden:YES];
            [_downloadButton setImage:[UIImage imageNamed:@"ic_download"] forState:UIControlStateNormal];
            _downloadButtonStatus = DownloadButtonStatusDownload;
            _taskStatusLabel.text = @"Ready";
            break;
            
        case DownloadItemStatusStarted:
            
            [_downloadButton setEnabled:YES];
            [_cancelButton setEnabled:YES];
            [_downloadButton setHidden:NO];
            [_cancelButton setHidden:NO];
            [_progressView setHidden:NO];
            [_downloadButton setImage:[UIImage imageNamed:@"ic_pause"] forState:UIControlStateNormal];
            _downloadButtonStatus = DownloadButtonStatusPause;
            _taskStatusLabel.text = @"Downloading...";
            break;
        case DownloadItemStatusPending:
            
            [_downloadButton setEnabled:YES];
            [_cancelButton setEnabled:YES];
            [_downloadButton setHidden:NO];
            [_cancelButton setHidden:NO];
            [_progressView setHidden:NO];
            [_downloadButton setImage:[UIImage imageNamed:@"ic_pause"] forState:UIControlStateNormal];
            _downloadButtonStatus = DownloadButtonStatusPause;
            _taskStatusLabel.text = @"Pending...";
            break;
            
        case DownloadItemStatusPaused:
            
            [_downloadButton setEnabled:YES];
            [_cancelButton setEnabled:YES];
            [_downloadButton setHidden:NO];
            [_cancelButton setHidden:NO];
            [_progressView setHidden:NO];
            [_downloadButton setImage:[UIImage imageNamed:@"ic_play"] forState:UIControlStateNormal];
            _downloadButtonStatus = DownloadButtonStatusPlay;
            _taskStatusLabel.text = @"Paused";
            break;
            
        case DownloadItemStatusCancelled:
            
            [_downloadButton setEnabled:YES];
            [_cancelButton setEnabled:NO];
            [_downloadButton setHidden:NO];
            [_cancelButton setHidden:NO];
            [_progressView setHidden:YES];
            [_downloadButton setImage:[UIImage imageNamed:@"ic_download"] forState:UIControlStateNormal];
            _downloadButtonStatus = DownloadButtonStatusDownload;
            _taskStatusLabel.text = @"Cancel";
            break;
            
        case DownloadItemStatusCompleted:
            
            [_downloadButton setHidden:YES];
            [_cancelButton setHidden:YES];
            [_progressView setHidden:YES];
            _taskStatusLabel.text = @"Completed";
            break;
            
        case DownloadItemStatusError:
            
            [_downloadButton setEnabled:NO];
            [_cancelButton setEnabled:YES];
            [_progressView setHidden:YES];
            [_downloadButton setImage:[UIImage imageNamed:@"ic_download"] forState:UIControlStateNormal];
            _downloadButtonStatus = DownloadButtonStatusDownload;
            _taskStatusLabel.text = @"Error";
            break;
            
        case DownloadItemStatusExisted:
            
            [_downloadButton setHidden:YES];
            [_cancelButton setHidden:YES];
            [_progressView setHidden:YES];
            [_downloadButton setImage:[UIImage imageNamed:@"ic_download"] forState:UIControlStateNormal];
            _downloadButtonStatus = DownloadButtonStatusDownload;
            _taskStatusLabel.text = @"The Same links above";
            break;
        default:
            break;
    }
}

#pragma mark - setupLayout

- (void)setupLayoutForCell {
    
    [self setBackgroundColor:[UIColor clearColor]];
    
    _progresssCellView = [[UIView alloc] init];
    _progresssCellView.layer.cornerRadius = 6;
    [_progresssCellView setBackgroundColor:[UIColor whiteColor]];
    [self addSubview:_progresssCellView];
    [_progresssCellView mas_makeConstraints:^(MASConstraintMaker* make) {
        
        make.edges.equalTo(self).insets(UIEdgeInsetsMake(5, 5, 5, 5));
    }];
    ;
    CGFloat scale = FONTSIZE_SCALE;
    
    _taskNameLabel = [[UILabel alloc] init];
    _taskNameLabel.text = @"Task download name";
    [_taskNameLabel setTextColor:[UIColor blueColor]];
    [_taskNameLabel setFont:[UIFont boldSystemFontOfSize:16 * scale]];
    [self addSubview:_taskNameLabel];
    
    _taskLinkLabel = [[UILabel alloc] init];
    _taskLinkLabel.text = @"http://download";
    [_taskLinkLabel setFont:[UIFont systemFontOfSize:13 * scale]];
    [_taskLinkLabel setTextColor:[UIColor darkGrayColor]];
    [_progresssCellView addSubview:_taskLinkLabel];
    
    _taskStatusLabel = [[UILabel alloc] init];
    _taskStatusLabel.text = @"Downloading...";
    [_taskStatusLabel setFont:[UIFont systemFontOfSize:10 * scale]];
    [_taskStatusLabel setTextColor:[UIColor darkGrayColor]];
    [_progresssCellView addSubview:_taskStatusLabel];
    
    _taskDetailLabel = [[UILabel alloc] init];
    _taskDetailLabel.text = @"0% - 30kb/24M - About 20 minute";
    [_taskDetailLabel setFont:[UIFont systemFontOfSize:9 * scale]];
    [_taskDetailLabel setTextColor:[UIColor darkGrayColor]];
    [_progresssCellView addSubview:_taskDetailLabel];
    
    _downloadButton = [[UIButton alloc] init];
    [_downloadButton setTitleColor:[UIColor whiteColor] forState:UIControlStateHighlighted];
    [_downloadButton addTarget:self action:@selector(downloadAction:) forControlEvents:UIControlEventTouchUpInside];
    [_downloadButton setImage:[UIImage imageNamed:@"ic_download"] forState:UIControlStateNormal];
    [_progresssCellView addSubview:_downloadButton];
    
    _cancelButton = [[UIButton alloc] init];
    [_cancelButton addTarget:self action:@selector(stopAction:) forControlEvents:UIControlEventTouchUpInside];
    [_cancelButton setImage:[UIImage imageNamed:@"ic_stop"] forState:UIControlStateNormal];
    [_progresssCellView addSubview:_cancelButton];
    
    _progressView = [[UIProgressView alloc] init];
    _progressView.progress = 0;
    [_progresssCellView addSubview:_progressView];
    
    [_taskNameLabel mas_makeConstraints:^(MASConstraintMaker* make) {
        
        make.top.equalTo(_progresssCellView).offset(20);
        make.left.equalTo(_progresssCellView).offset(10);
    }];
    
    [_taskLinkLabel mas_makeConstraints:^(MASConstraintMaker* make) {
        
        make.top.equalTo(_taskNameLabel.mas_bottom).offset(8);
        make.right.equalTo(_downloadButton.mas_left).offset(-5);
        make.left.equalTo(_progresssCellView).offset(10);
    }];
    
    [_progressView mas_makeConstraints:^(MASConstraintMaker* make) {
        
        make.left.equalTo(_progresssCellView).offset(8);
        make.right.equalTo(_progresssCellView).offset(-8);
        make.bottom.equalTo(_progresssCellView).offset(-10);
    }];
    
    [_taskStatusLabel mas_makeConstraints:^(MASConstraintMaker* make) {
        
        make.bottom.equalTo(_progressView.mas_top).offset(-8);
        make.left.equalTo(_progresssCellView).offset(10);
    }];
    
    [_taskDetailLabel mas_makeConstraints:^(MASConstraintMaker* make) {
        
        make.bottom.equalTo(_progressView.mas_top).offset(-8);
        make.right.equalTo(_progresssCellView).offset(-8);
    }];
    
    [_cancelButton mas_makeConstraints:^(MASConstraintMaker* make) {
        
        make.right.equalTo(_progresssCellView).offset(-8);
        make.centerY.equalTo(_progresssCellView);
        make.width.and.height.mas_equalTo(35);
    }];
    
    [_downloadButton mas_makeConstraints:^(MASConstraintMaker* make) {
        
        make.right.equalTo(_cancelButton.mas_left).offset(-8);
        make.centerY.equalTo(_progresssCellView);
        make.width.and.height.mas_equalTo(35);
    }];
}

#pragma mark - downloadAction

- (void)downloadAction:(UIButton *)sender {
    
    if(_downloadButtonStatus == DownloadButtonStatusPause) {
        
        if (_delegate && [_delegate respondsToSelector:@selector(pauseDownloadWithItemID:)]) {
            
            [_delegate pauseDownloadWithItemID:_identifier];
        }
    } else if (_downloadButtonStatus == DownloadButtonStatusPlay) {
        
        if (_delegate && [_delegate respondsToSelector:@selector(resumeDownloadWithItemID:)]) {
            
            [_delegate resumeDownloadWithItemID:_identifier];
        }
    } else {
        
        if (_delegate && [_delegate respondsToSelector:@selector(startDownloadFromURL:)]) {
            
            [_delegate startDownloadFromURL:_link];
        }
    }
}

#pragma mark - cancelAction

- (void)stopAction:(UIButton *)sender {
    
    if (_delegate && [_delegate respondsToSelector:@selector(startDownloadFromURL:)]) {
        
        [_delegate cancelDownloadWithItemID:_identifier];
    }
}

@end
