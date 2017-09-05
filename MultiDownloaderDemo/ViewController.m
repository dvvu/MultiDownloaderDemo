//
//  ViewController.m
//  MultiDownloaderDemo
//
//  Created by Doan Van Vu on 8/24/17.
//  Copyright © 2017 Doan Van Vu. All rights reserved.
//

#import "ViewController.h"

@interface ViewController ()

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
}

+ (void)showConnectInternetAlert:(UIViewController *)controller withTitle:(NSString *)title andMessage:(NSString *)message {
    
    UIAlertController* alert = [UIAlertController alertControllerWithTitle:title message:message preferredStyle:UIAlertControllerStyleAlert];
    
    UIAlertAction* yesButton = [UIAlertAction actionWithTitle:@"OK" style:UIAlertActionStyleDefault handler:^(UIAlertAction* action) {
        
        [[UIApplication sharedApplication] openURL:[NSURL URLWithString:@"prefs:root=WIFI"]];
    }];
    
    [alert addAction:yesButton];
    
    dispatch_async(dispatch_get_main_queue(), ^{
        
        [controller presentViewController:alert animated:YES completion:nil];
    });
}

@end
