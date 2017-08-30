//
//  ViewController.m
//  MultiDownloaderDemo
//
//  Created by Doan Van Vu on 8/24/17.
//  Copyright © 2017 Doan Van Vu. All rights reserved.
//

#import "MultiDownloadManager.h"
#import "ViewController.h"

@interface ViewController ()

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
    
}

- (IBAction)start1:(id)sender {

    [_downloadTasks startDownloadFromURL:_url];
}
- (IBAction)pause1:(id)sender {
    
}
- (IBAction)resume1:(id)sender {
    

}
- (IBAction)cancel1:(id)sender {
  
}
- (IBAction)start2:(id)sender {
 
}
- (IBAction)pause2:(id)sender {
   
}
- (IBAction)resume2:(id)sender {
    
}
- (IBAction)cancel2:(id)sender {
    
}
- (IBAction)resumeAll:(id)sender {
    
}
- (IBAction)pauseAll:(id)sender {
    
}

#pragma mark - MultiDownloadItem


@end
