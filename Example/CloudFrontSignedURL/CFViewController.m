//
//  CFViewController.m
//  CloudFrontSignedURL
//
//  Created by 22544424 on 08/16/2020.
//  Copyright (c) 2020 22544424. All rights reserved.
//

#import "CFViewController.h"
@import CloudFrontSignedURL;

#define TEST_PRIVATE_KEY    @"-----BEGIN RSA PRIVATE KEY-----\n" \
                            "-----END RSA PRIVATE KEY-----"

#define TEST_PUBLIC_KEY     @"-----BEGIN PUBLIC KEY-----\n" \
                            "-----END PUBLIC KEY-----"

#define TEST_ACCESS_KEY     @"A...."

@interface CFViewController ()
@property (weak, nonatomic) IBOutlet UILabel *linkLabel;
@end

@implementation CFViewController

- (IBAction)didTapTest:(id)sender {
    // Test conditions
    NSURL *testURL = [NSURL URLWithString:@"https://resources.myfiziq.io/index.html"];
    NSDate *expire = [NSDate dateWithTimeInterval:600.0 sinceDate:[NSDate date]];
    // Generate the signed url
    NSURL *signedURL = [CloudFrontSignedURL signedCannedPolicyURLForURL:testURL
                                                              accessKey:TEST_ACCESS_KEY
                                                             privateKey:TEST_PRIVATE_KEY
                                                         expirationTime:expire];
    self.linkLabel.text = signedURL.absoluteString;
}

@end
