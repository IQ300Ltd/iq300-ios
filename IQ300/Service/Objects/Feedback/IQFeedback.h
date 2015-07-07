//
//  IQFeedback.h
//  IQ300
//
//  Created by Tayphoon on 26.06.15.
//  Copyright (c) 2015 Tayphoon. All rights reserved.
//

#import <Foundation/Foundation.h>

@class RKObjectMapping;
@class IQFeedbackType;
@class IQFeedbackCategory;

@interface IQPlatformInfo : NSObject

@property (nonatomic, readonly) NSString * appVersion;
@property (nonatomic, readonly) NSString * osVersion;
@property (nonatomic, readonly) NSString * platformName;

@end

@interface IQFeedback : NSObject

@property (nonatomic, strong) NSNumber * categoryId;
@property (nonatomic, strong) NSString * type;
@property (nonatomic, strong) NSString * feedbackDescription;
@property (nonatomic, strong) NSArray * attachmentIds;

@property (nonatomic, strong) IQFeedbackType * feedbackType;
@property (nonatomic, strong) IQFeedbackCategory * feedbackCategory;
@property (nonatomic, readonly) IQPlatformInfo * platformInfo;

+ (RKObjectMapping*)objectMapping;

+ (RKObjectMapping*)requestObjectMapping;

@end
