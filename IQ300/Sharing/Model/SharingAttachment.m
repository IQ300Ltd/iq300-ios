//
//  SharingAttachments.m
//  IQ300
//
//  Created by Vladislav Grigoryev on 02/02/16.
//  Copyright © 2016 Tayphoon. All rights reserved.
//

#import "SharingAttachment.h"
#import "SharingConstants.h"
#import "FileStore.h"

@interface SharingAttachment ()

@property (nonatomic, strong) NSString *typeIdentifier;

@end

@implementation SharingAttachment

- (instancetype)initWithPath:(NSString *)filePath displayName:(NSString *)displayName contentType:(NSString *)contentType {
    self = [super init];
    if (self) {
        _localURL = filePath;
        _displayName = displayName;
        _contentType = contentType;
        
        _typeIdentifier = (__bridge NSString * _Nonnull)(UTTypeCreatePreferredIdentifierForTag(kUTTagClassMIMEType, (__bridge CFStringRef _Nonnull)(self.contentType), nil));
    }
    return self;
}

- (instancetype)initWithData:(NSData *)fileData displayName:(NSString *)displayName contentType:(NSString *)contentType {
    self = [super init];
    if (self) {
        _fileData = fileData;
        _displayName = displayName;
        _contentType = contentType;
        
        _typeIdentifier = (__bridge NSString * _Nonnull)(UTTypeCreatePreferredIdentifierForTag(kUTTagClassMIMEType, (__bridge CFStringRef _Nonnull)(self.contentType), nil));
    }
    return self;
}

- (NSString *)getLocalURL {
    if (!_localURL) {
        if (_fileData) {
            NSError *error;
            NSString *fileName = [[FileStore sharedStore] storeData:_fileData forKey:_displayName MIMEType:_contentType error:&error];
            _localURL = [[FileStore sharedStore] filePathURLForFileName:fileName].path;
        }
    }
    return _localURL;
}

- (id)activityViewControllerPlaceholderItem:(UIActivityViewController *)activityViewController {
    return [NSData data];
}

- (id)activityViewController:(UIActivityViewController *)activityViewController itemForActivityType:(NSString *)activityType {
    if ([activityType hasPrefix:IQ_ACTIVITY_TYPE_PREFIX]) {
        return self;
    }
    else {
        if ([activityType isEqualToString:UIActivityTypeSaveToCameraRoll]) {
            return _localURL;
        }
        
        if (!_fileData) {
            _fileData = [NSData dataWithContentsOfFile:_localURL];
        }
        return _fileData;
    }
}

- (NSString *)activityViewController:(UIActivityViewController *)activityViewController dataTypeIdentifierForActivityType:(NSString *)activityType {
    if ([activityType hasPrefix:IQ_ACTIVITY_TYPE_PREFIX]) {
        return SHARING_ATTACHMENT_UTI;
    }
    else {
        return _typeIdentifier;
    }
}

- (NSString *)activityViewController:(UIActivityViewController *)activityViewController subjectForActivityType:(NSString *)activityType {
    return _displayName;
}

@end
