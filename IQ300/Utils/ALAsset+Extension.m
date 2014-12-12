//
//  ALAsset+Extension.m
//  IQ300
//
//  Created by Tayphoon on 08.12.14.
//  Copyright (c) 2014 Tayphoon. All rights reserved.
//

#import "ALAsset+Extension.h"

@implementation ALAsset (Extension)

- (NSString*)MIMEType {
    ALAssetRepresentation *rep = [self defaultRepresentation];
    
    NSString* MIMEType = (__bridge_transfer NSString*)UTTypeCopyPreferredTagWithClass((__bridge CFStringRef)[rep UTI], kUTTagClassMIMEType);
    return MIMEType;
}

- (NSString*)fileName {
    ALAssetRepresentation *rep = [self defaultRepresentation];
    return [rep filename];
}

@end
