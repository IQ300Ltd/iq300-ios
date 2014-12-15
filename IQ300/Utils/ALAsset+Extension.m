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

- (BOOL)writeToFile:(NSURL *)fileUrl error:(NSError **)error {
    ALAssetRepresentation * representation = [self defaultRepresentation];
    NSString * filePath = [fileUrl path];

    if ([[NSFileManager defaultManager] createFileAtPath:filePath contents:nil attributes:nil]) {
        NSOutputStream *outPutStream = [NSOutputStream outputStreamToFileAtPath:filePath append:YES];
        [outPutStream open];
        
        long long offset = 0;
        NSUInteger bytesRead = 0;
        
        size_t bufferSize = 131072;
        uint8_t * buffer = malloc(bufferSize);
        while (offset < [representation size] && [outPutStream hasSpaceAvailable]) {
            bytesRead = [representation getBytes:buffer fromOffset:offset length:bufferSize error:error];
            [outPutStream write:buffer maxLength:bytesRead];
            offset = offset+bytesRead;
        }
        
        [outPutStream close];
        free(buffer);
        
        return YES;
    }
    else {
        NSString * localizedError = [NSString stringWithFormat:@"Error create file with code: %d - message: %s", errno, strerror(errno)];
        *error = [NSError errorWithDomain:@"" code:errno userInfo:@{ NSLocalizedDescriptionKey : localizedError }];
    }
    return NO;
}

@end
