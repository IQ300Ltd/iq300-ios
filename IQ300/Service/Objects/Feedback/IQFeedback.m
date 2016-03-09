//
//  IQFeedback.m
//  IQ300
//
//  Created by Tayphoon on 26.06.15.
//  Copyright (c) 2015 Tayphoon. All rights reserved.
//
#import <RestKit/RestKit.h>

#import "IQFeedback.h"
#import "IQFeedbackType.h"
#import "IQFeedbackCategory.h"
#import "UIDevice-Hardware.h"

@implementation IQPlatformInfo

- (id)init {
    self = [super init];
    if (self) {
        NSDictionary * infoDictionary = [[NSBundle mainBundle] infoDictionary];
        NSString * majorVersion = [infoDictionary objectForKey:@"CFBundleShortVersionString"];
        NSString * minorVersion = [infoDictionary objectForKey:@"CFBundleVersion"];
        _appVersion = [NSString stringWithFormat:@"Version %@ (%@)", majorVersion, minorVersion];
        _osVersion = [[UIDevice currentDevice] systemVersion];
        NSString * platformString = [[UIDevice currentDevice] platformString];
        _platformName = [NSString stringWithFormat:@"%@ (%@)", platformString, [[UIDevice currentDevice] platform]];
    }
    return self;
}

+ (RKObjectMapping*)objectMapping {
    RKObjectMapping * mapping = [RKObjectMapping mappingForClass:[self class]];
    [mapping addAttributeMappingsFromDictionary:@{
                                                  @"app_version"    : @"appVersion",
                                                  @"os_version"    : @"osVersion",
                                                  @"device_info"    : @"platformName"
                                                  }];
    return mapping;
}

@end

@interface IQFeedback ()

@property (nonatomic, strong) NSMutableArray *mutableAttachments;
@property (nonatomic, strong) NSMutableArray *mutableAttachmentIds;

@end

@implementation IQFeedback

- (id)init {
    self = [super init];
    if (self) {
        _platformInfo = [[IQPlatformInfo alloc] init];
        
        _mutableAttachments = [[NSMutableArray alloc] init];
        _mutableAttachmentIds = [[NSMutableArray alloc] init];
    }
    return self;
}

+ (RKObjectMapping*)objectMapping {
    RKObjectMapping * mapping = [RKObjectMapping mappingForClass:[self class]];
    [mapping addAttributeMappingsFromDictionary:@{
                                                  @"category_id"    : @"feedbackCategory.categoryId",
                                                  @"report_type"    : @"feedbackType.type",
                                                  @"attachment_ids" : @"attachmentIds",
                                                  @"description"    : @"feedbackDescription"
                                                  }];
    
    RKRelationshipMapping * relation = [RKRelationshipMapping relationshipMappingFromKeyPath:@"additional_data"
                                                                                   toKeyPath:@"platformInfo"
                                                                                 withMapping:[IQPlatformInfo objectMapping]];
    [mapping addPropertyMapping:relation];

    return mapping;
}

+ (RKObjectMapping*)requestObjectMapping {
    RKObjectMapping * objectMapping = [self objectMapping];
    
    return [objectMapping inverseMapping];
}

- (void)addAttachement:(id<IQAttachment>)attachment {
    [_mutableAttachments addObject:attachment];
}

- (void)removeAttachementAtIndex:(NSUInteger)index {
    [_mutableAttachments removeObjectAtIndex:index];
}

- (id <IQAttachment>)attachmentAtIndex:(NSUInteger)index {
    return [_mutableAttachments objectAtIndex:index];
}

- (void)addAttachmentId:(NSNumber *)attachmentId {
    [_mutableAttachmentIds addObject:attachmentId];
}

- (NSArray *)attachements {
    return [_mutableAttachments copy];
}

- (NSArray *)attachmentIds {
    return [_mutableAttachmentIds copy];
}



@end
