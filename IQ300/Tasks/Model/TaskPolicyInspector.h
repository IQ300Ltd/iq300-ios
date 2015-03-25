//
//  TaskPolicyInspector.h
//  IQ300
//
//  Created by Tayphoon on 25.03.15.
//  Copyright (c) 2015 Tayphoon. All rights reserved.
//

#import <Foundation/Foundation.h>

@class IQTask;
@class IQTaskMember;

@interface TaskPolicyInspector : NSObject

@property (nonatomic, readonly) IQTask * task;

- (id)initWithTask:(IQTask*)task;

- (void)requestUserPoliciesWithCompletion:(void (^)(NSError * error))completion;

- (BOOL)isActionAvailable:(NSString*)action inCategory:(NSString*)category;

- (NSArray*)availableActionsForCategory:(NSString*)category;

- (NSArray*)availableActionsForMember:(IQTaskMember*)member category:(NSString*)category;

@end
