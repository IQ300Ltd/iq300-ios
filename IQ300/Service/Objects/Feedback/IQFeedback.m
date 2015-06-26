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

@implementation IQFeedback

+ (RKObjectMapping*)objectMapping {
    RKObjectMapping * mapping = [RKObjectMapping mappingForClass:[self class]];
    [mapping addAttributeMappingsFromDictionary:@{
                                                  @"category_id"    : @"feedbackCategory.categoryId",
                                                  @"report_type"    : @"feedbackType.type",
                                                  @"attachment_ids" : @"attachmentIds",
                                                  @"description"    : @"feedbackDescription"
                                                  }];
    return mapping;
}

+ (RKObjectMapping*)requestObjectMapping {
    RKObjectMapping * objectMapping = [self objectMapping];
    
    return [objectMapping inverseMapping];
}

@end
