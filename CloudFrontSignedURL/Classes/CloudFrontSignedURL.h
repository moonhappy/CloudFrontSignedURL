//
// Copyright 2020 github.com/moonhappy
//
// Permission is hereby granted, free of charge, to any person obtaining a copy of this software and associated
// documentation files (the "Software"), to deal in the Software without restriction, including without limitation the
// rights to use, copy, modify, merge, publish, distribute, sublicense, and/or sell copies of the Software, and to
// permit persons to whom the Software is furnished to do so, subject to the following conditions:
//
//  The above copyright notice and this permission notice shall be included in all copies or substantial portions of the
//  Software.
//
// THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE
// WARRANTIES OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR
// COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR
// OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.
//

#import <Foundation/Foundation.h>
#import <Security/Security.h>

// Largely based on:
// - Apple's signing doc: https://developer.apple.com/documentation/security/certificate_key_and_trust_services/keys/signing_and_verifying
// - CF Canned Policy Signed URL doc: https://docs.aws.amazon.com/AmazonCloudFront/latest/DeveloperGuide/private-content-creating-signed-url-canned-policy.html
// - CF Custom Policy Signed URL doc: https://docs.aws.amazon.com/AmazonCloudFront/latest/DeveloperGuide/private-content-creating-signed-url-custom-policy.html

/** Helper to generate AWS CloudFront Signed URL. */
@interface CloudFrontSignedURL : NSObject
/**
 Creates an AWS CloudFront Signed URL using the Canned Policy technique.
 @param resource The URL to the AWS CloudFront resource. This can also be Route53 domain if the appropriate CNAME and routing is configured accordingly.
 @param akey The AWS CloudFront account key (generated during the AWS CloudFront key-pair generation).
 @param privatePEMkey The private RSA PEM key of the AWS CloudFront private key (generated during the AWS CloudFront key-pair generation).
 @param expires The date-time when the URL will expire (i.e. date-time the URL will cease to work).
 @return URL of the generated AWS CloudFront Signed URL, or nil if an error occurred.
*/
+ (NSURL * _Nullable)signedCannedPolicyURLForURL:(NSURL * _Nonnull)resource
                                       accessKey:(NSString * _Nonnull)akey
                                      privateKey:(NSString * _Nonnull)privatePEMkey
                                  expirationTime:(NSDate * _Nonnull)expires;
@end
