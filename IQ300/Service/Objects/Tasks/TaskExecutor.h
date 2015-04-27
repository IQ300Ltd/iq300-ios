//
//  TaskExecutor.h
//  IQ300
//
//  Created by Tayphoon on 20.04.15.
//  Copyright (c) 2015 Tayphoon. All rights reserved.
//

#import <Foundation/Foundation.h>

@class RKObjectMapping;

@interface TaskExecutor : NSObject

@property (nonatomic, strong) NSNumber * executorId;
@property (nonatomic, strong) NSString * executorName;

+ (RKObjectMapping*)objectMapping;

@end
