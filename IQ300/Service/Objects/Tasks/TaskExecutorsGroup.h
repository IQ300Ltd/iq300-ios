//
//  TaskExecutorsGroup.h
//  IQ300
//
//  Created by Tayphoon on 20.04.15.
//  Copyright (c) 2015 Tayphoon. All rights reserved.
//

#import <Foundation/Foundation.h>

@class RKObjectMapping;

@interface TaskExecutorsGroup : NSObject

@property (nonatomic, strong) NSArray * executors;

+ (RKObjectMapping*)objectMapping;

@end
