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

#import "CloudFrontSignedURL.h"

#define CFSURL_CANNED_POLICY            @"{\"Statement\":[{\"Resource\":%@, \"Condition\":{\"DateLessThan\":{\"AWS:EpochTime\":%ld}}}]}"
#define CFSURL_URL_FORMAT               @"%@?Expires=%ld&Signature=%@&Key-Pair-Id=%@"

@implementation CloudFrontSignedURL

#pragma mark - Private Methods

+ (NSString *)cannedPolicyForURL:(NSURL *)url expiration:(NSTimeInterval)expire {
    if (!url) {
        return nil;
    }
    return [NSString stringWithFormat:CFSURL_CANNED_POLICY, url.absoluteString, (NSUInteger)expire];
}

+ (NSData *)rsaSignCannedPolicy:(NSString *)policy key:(SecKeyRef)privateKey {
    if (!privateKey || !policy) {
        return nil;
    }
    SecKeyAlgorithm algorithm = kSecKeyAlgorithmRSASignatureMessagePKCS1v15SHA1;
    if (!SecKeyIsAlgorithmSupported(privateKey, kSecKeyOperationTypeSign, algorithm)) {
        return nil;
    }
    NSData *data2sign = [policy dataUsingEncoding:NSUTF8StringEncoding];
    NSData *signature = nil;
    CFErrorRef error = NULL;
    signature = (NSData *)CFBridgingRelease(SecKeyCreateSignature(privateKey, algorithm, (__bridge CFDataRef)data2sign, &error));
    if (error) {
        NSError *err = CFBridgingRelease(error);  // ARC takes ownership
        if (err) {
            return nil;
        }
    }
    return signature;
}

+ (NSString *)awsBase64EscapedForSignature:(NSData *)signature {
    if (!signature) {
        return nil;
    }
    NSString *base64Signature = [signature base64EncodedStringWithOptions:0];
    if (!base64Signature) {
        return nil;
    }
    base64Signature = [base64Signature stringByReplacingOccurrencesOfString:@"+" withString:@"-"];
    base64Signature = [base64Signature stringByReplacingOccurrencesOfString:@"=" withString:@"_"];
    base64Signature = [base64Signature stringByReplacingOccurrencesOfString:@"/" withString:@"~"];
    return base64Signature;
}

#pragma mark - Public Methods

+ (SecKeyRef)secKeyRefForRSAPrivateKeyPEM:(NSString *)key {
    if (!key || ![key containsString:@"-----BEGIN RSA PRIVATE KEY-----"]) {
        return nil;
    }
    // Extract the base64 encoding of the key.
    NSArray<NSString *> *keyComponents = [key componentsSeparatedByString:@"-----"];
    if (!keyComponents || keyComponents.count != 5) {
        return nil;
    }
    NSString *keyBase64 = [[keyComponents objectAtIndex:2] stringByReplacingOccurrencesOfString:@"\n" withString:@""];
    NSData *binaryKey = [[NSData alloc] initWithBase64EncodedString:keyBase64 options:0];
    if (!binaryKey) {
        return nil;
    }
    // Convert to SecKeyRef.
    NSDictionary *keyOptions = @{((__bridge NSString*)kSecAttrKeyType):((__bridge NSString*)kSecAttrKeyTypeRSA),
                                 ((__bridge NSString*)kSecAttrKeyClass):((__bridge NSString*)kSecAttrKeyClassPrivate)};
    SecKeyRef skr = SecKeyCreateWithData(((__bridge CFDataRef)binaryKey), ((__bridge CFDictionaryRef)keyOptions), nil);
    return skr;
}

+ (NSURL *)signedCannedPolicyURLForURL:(NSURL *)resource
                             accessKey:(NSString *)akey
                            privateKey:(NSString *)privatePEMkey
                        expirationTime:(NSDate *)expires {
    if (!resource || [resource isFileURL] || !akey || !expires || !privatePEMkey) {
        return nil;
    }
    // 1. Generate the access policy
    NSTimeInterval expireEpoch = [expires timeIntervalSince1970];
    NSString *policy = [CloudFrontSignedURL cannedPolicyForURL:resource expiration:expireEpoch];
    // 2. Sign the policy
    SecKeyRef pkey = [CloudFrontSignedURL secKeyRefForRSAPrivateKeyPEM:privatePEMkey];
    NSData *signature = [CloudFrontSignedURL rsaSignCannedPolicy:policy key:pkey];
    NSString *signatureBase64 = [CloudFrontSignedURL awsBase64EscapedForSignature:signature];
    if (!signatureBase64) {
        return nil;
    }
    // 3. Create the URL
    NSString *signedURLPath = [NSString stringWithFormat:CFSURL_URL_FORMAT, resource.absoluteString, (NSUInteger)expireEpoch, signatureBase64, akey];
    return [NSURL URLWithString:signedURLPath];
}

@end
