//
//  CFViewController.m
//  CloudFrontSignedURL
//
//  Created by 22544424 on 08/16/2020.
//  Copyright (c) 2020 22544424. All rights reserved.
//

#import "CFViewController.h"
@import CloudFrontSignedURL;

#define TEST_URL            @"https://moonhappy.io/index.html"
#define TEST_ACCESS_KEY     @"AAAAAAAA"


@interface CFViewController ()
@property (weak, nonatomic) IBOutlet UIButton *linkButton;
@end

@implementation CFViewController

- (IBAction)didTapTest:(id)sender {
    // Test conditions
    NSURL *testURL = [NSURL URLWithString:TEST_URL];
    NSDate *expire = [NSDate dateWithTimeInterval:600.0 sinceDate:[NSDate date]];
    // Load the private key to sign with.
    NSString *derKeyPath = [[NSBundle mainBundle] pathForResource:@"private" ofType:@"der"];
    if (!derKeyPath) {
        return;
    }
    NSData *derKey = [NSData dataWithContentsOfFile:derKeyPath];
    // Generate the signed url
    NSURL *signedURL = [testURL cloudFrontSignedCannedPolicyURLForAccessKey:TEST_ACCESS_KEY
                                                                 privateKey:derKey
                                                                 expiration:expire];
    [self.linkButton setTitle:signedURL.absoluteString forState:UIControlStateNormal];
}

- (IBAction)didTapLink:(id)sender {
    NSURL *link = [[NSURL alloc] initWithString:self.linkButton.titleLabel.text];
    [[UIApplication sharedApplication] openURL:link options:@{} completionHandler:nil];
}

@end
