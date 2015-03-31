//
//  TaskPolicyInspector.m
//  IQ300
//
//  Created by Tayphoon on 25.03.15.
//  Copyright (c) 2015 Tayphoon. All rights reserved.
//
#import <objc/runtime.h>

#import "TaskPolicyInspector.h"
#import "TaskPolicies.h"
#import "IQService+Tasks.h"
#import "IQSession.h"
#import "IQTaskMember.h"
#import "IQTask.h"
#import "IQUser.h"

@interface  NSObject(Enhanced)

+ (BOOL)hasPropertyNamed:(NSString *)propertyNamed;

@end

@implementation NSObject(Enhanced)

+ (BOOL)hasPropertyNamed:(NSString *)propertyNamed {
    return (class_getProperty(self, [propertyNamed UTF8String]) != NULL);
}

@end

@interface TaskPolicyInspector() {
    TaskPolicies * _policies;
}

@end

@implementation TaskPolicyInspector

- (id)init {
    return [self initWithTask:nil];
}

- (id)initWithTask:(IQTask*)task {
    NSParameterAssert(task);
    
    self = [super init];
    if (self) {
        _task = task;
    }
    return self;
}

- (void)requestUserPoliciesWithCompletion:(void (^)(NSError * error))completion {
    [[IQService sharedService] policiesForTaskWithId:_task.taskId
                                             handler:^(BOOL success, TaskPolicies *  policies, NSData *responseData, NSError *error) {
                                                 if (success) {
                                                     _policies = policies;
                                                 }
                                                 if(completion) {
                                                     completion(error);
                                                 }
                                             }];
}

- (BOOL)isActionAvailable:(NSString*)action inCategory:(NSString*)category {
    if (_policies && [[_policies class] hasPropertyNamed:category]) {
        NSArray * policies = [_policies valueForKey:category];
        
        if ([policies isKindOfClass:[NSArray class]]) {
            return [policies containsObject:action];
        }
    }
    
    return NO;
}

- (NSArray*)availableActionsForCategory:(NSString*)category {
    if (_policies && [[_policies class] hasPropertyNamed:category]) {
        NSArray * policies = [_policies valueForKey:category];
        return policies;
    }
    
    return nil;
}

- (NSArray*)availableActionsForMember:(IQTaskMember*)member category:(NSString*)category {
    NSMutableArray * policies = (_policies && [[_policies class] hasPropertyNamed:category]) ? [[_policies valueForKey:category] mutableCopy] : nil;

    if ([category isEqualToString:@"users"]) {
        if([member.taskRole isEqualToString:@"watcher"]) {
            if([member.user.userId isEqualToNumber:[IQSession defaultSession].userId]) {
                return @[@"leave"];
            }
            else {
                [policies removeObject:@"leave"];
                return policies;
            }
        }
        return nil;
    }
    
    if (policies) {
        return policies;
    }
    
    return nil;
}

@end
