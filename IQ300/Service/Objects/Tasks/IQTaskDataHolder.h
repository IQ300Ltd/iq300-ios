//
//  IQTaskDataHolder.h
//  IQ300
//
//  Created by Tayphoon on 16.04.15.
//  Copyright (c) 2015 Tayphoon. All rights reserved.
//

#import <Foundation/Foundation.h>

@class IQTask;
@class IQCommunity;
@class IQComplexity;
@class RKObjectMapping;

@interface IQTaskDataHolder : NSObject

@property (nonatomic, strong) NSNumber * taskId;
@property (nonatomic, strong) NSString * title;
@property (nonatomic, strong) IQCommunity * community;
@property (nonatomic, strong) NSArray * executors;
@property (nonatomic, readonly) NSArray * executorIds;
@property (nonatomic, readonly) NSNumber * firstExecutorId;
@property (nonatomic, strong) NSDate  * startDate;
@property (nonatomic, strong) NSDate  * endDate;
@property (nonatomic, strong) NSString * taskDescription;

@property (nonatomic, strong) NSNumber *estimatedTimeSeconds;
@property (nonatomic, strong) NSNumber *parentTaskAccess;

@property (nonatomic, strong) IQComplexity *complexity;

@property (nonatomic, strong) NSNumber *parentTaskId;
@property (nonatomic, strong) NSDate *parentStartDate;
@property (nonatomic, strong) NSDate *parentEndDate;

+ (IQTaskDataHolder*)holderWithTask:(IQTask*)task;

+ (RKObjectMapping*)createRequestObjectMapping;

+ (RKObjectMapping*)editRequestObjectMapping;

- (void)setParentTask:(IQTask *)parentTask;

@end
