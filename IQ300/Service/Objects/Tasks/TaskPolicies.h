//
//  TaskPolicies.h
//  IQ300
//
//  Created by Tayphoon on 25.03.15.
//  Copyright (c) 2015 Tayphoon. All rights reserved.
//

#import <Foundation/Foundation.h>

@class RKObjectMapping;

@interface TaskPolicies : NSObject

@property (nonatomic, strong) NSArray * details;
@property (nonatomic, strong) NSArray * status;
@property (nonatomic, strong) NSArray * todoItems;
@property (nonatomic, strong) NSArray * comments;
@property (nonatomic, strong) NSArray * documents;
@property (nonatomic, strong) NSArray * users;
@property (nonatomic, strong) NSArray * activities;

+ (RKObjectMapping*)objectMapping;

@end
