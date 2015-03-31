//
//  TaskTabItemController.h
//  IQ300
//
//  Created by Tayphoon on 24.03.15.
//  Copyright (c) 2015 Tayphoon. All rights reserved.
//

#import <Foundation/Foundation.h>

@class TaskPolicyInspector;

@protocol TaskTabItemController <NSObject>

@property (nonatomic, strong) NSNumber * badgeValue;
@property (nonatomic, readonly) NSString * category;
@property (nonatomic, weak) TaskPolicyInspector * policyInspector;

@end
