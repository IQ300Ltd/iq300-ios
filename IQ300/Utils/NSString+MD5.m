//
//  NSString+MD5.m
//  IQ300
//
//  Created by Tayphoon on 30.01.15.
//  Copyright (c) 2015 Tayphoon. All rights reserved.
//
#import <CommonCrypto/CommonDigest.h>

#import "NSString+MD5.h"

@implementation NSString (MD5)

- (NSString*)md5String {
    if(self.length > 0) {
        const char *ptr = [self UTF8String];
        unsigned char md5Buffer[CC_MD5_DIGEST_LENGTH];
        
        CC_MD5(ptr, (CC_LONG)strlen(ptr), md5Buffer);
        
        NSMutableString *output = [NSMutableString stringWithCapacity:CC_MD5_DIGEST_LENGTH * 2];
        for(int i = 0; i < CC_MD5_DIGEST_LENGTH; i++)
            [output appendFormat:@"%02x",md5Buffer[i]];
        
        return output;
    }
    return nil;
}

@end
