//
//  DeviceToken.m
//  IQ300
//
//  Created by Tayphoon on 10.02.15.
//  Copyright (c) 2015 Tayphoon. All rights reserved.
//
#import <SSKeychain/SSKeychain.h>

#import "DeviceToken.h"

@implementation DeviceToken

+ (NSString *)uniqueIdentifier {
    NSString * bundleIdentifier = [[[NSBundle mainBundle] infoDictionary] objectForKey:(NSString*)kCFBundleIdentifierKey];

    NSString * uniqueIdentifier = [SSKeychain passwordForService:bundleIdentifier account:@"incoding"];
    if (uniqueIdentifier == nil) {
        uniqueIdentifier  = [[[UIDevice currentDevice] identifierForVendor] UUIDString];
        [SSKeychain setPassword:uniqueIdentifier forService:bundleIdentifier account:@"incoding"];
    }
    
    return uniqueIdentifier;
}

@end
