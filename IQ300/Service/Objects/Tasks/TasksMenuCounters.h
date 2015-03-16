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
@property (nonatomic, strong) NSNumber * inbox;
@property (nonatomic, strong) NSNumber * outbox;
@property (nonatomic, strong) NSNumber * total;

+ (RKObjectMapping*)objectMapping;

@end
