//
//  SharingAttachments.h
//  IQ300
//
//  Created by Vladislav Grigoryev on 02/02/16.
//  Copyright © 2016 Tayphoon. All rights reserved.
//

#import <Foundation/Foundation.h>

#define SHARING_ATTACHMENT_UTI @"ru.iq300.sharing.attachment"

@interface SharingAttachment : NSObject <UIActivityItemSource>

@property (nonatomic, strong) NSString *localURL;
@property (nonatomic, strong) NSString *displayName;
@property (nonatomic, strong) NSString *contentType;

@property (nonatomic, strong) NSData *fileData;

- (instancetype)initWithData:(NSData *)fileData displayName:(NSString *)displayName contentType:(NSString *)contentType;
- (instancetype)initWithPath:(NSString *)filePath displayName:(NSString *)displayName contentType:(NSString *)contentType;

@end
