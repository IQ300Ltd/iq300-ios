//
//  FilterCounters.h
//  IQ300
//
//  Created by Tayphoon on 03.03.15.
//  Copyright (c) 2015 Tayphoon. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "TaskFilterItem.h"

@class RKObjectMapping;

@interface CommunityFilter : NSObject <TaskFilterItem>

@property (nonatomic, strong) NSNumber * communityId;
@property (nonatomic, strong) NSString * title;
@property (nonatomic, strong) NSNumber * count;

+ (RKObjectMapping*)objectMapping;

@end

@interface TaskFilterCounters : NSObject

@property (nonatomic, strong) NSArray * communities;
@property (nonatomic, strong) NSDictionary * statuses;

+ (RKObjectMapping*)objectMapping;

@end
