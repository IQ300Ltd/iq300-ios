//
//  TasksMenuCounters.h
//  IQ300
//
//  Created by Tayphoon on 03.03.15.
//  Copyright (c) 2015 Tayphoon. All rights reserved.
//

#import <Foundation/Foundation.h>

@class RKObjectMapping;

@interface TasksMenuCounters : NSObject

@property (nonatomic, strong) NSNumber * overdue;
@property (nonatomic, strong) NSNumber * inboxNew;
@property (nonatomic, strong) NSNumber * inboxBrowsed;
@property (nonatomic, strong) NSNumber * outboxCompleted;
@property (nonatomic, strong) NSNumber * outboxRefused;
@property (nonatomic, strong) NSNumber * total;

+ (RKObjectMapping*)objectMapping;

@end
