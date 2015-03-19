//
//  TaskHelper.h
//  IQ300
//
//  Created by Tayphoon on 18.03.15.
//  Copyright (c) 2015 Tayphoon. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface TaskHelper : NSObject

+ (UIColor*)colorForTaskType:(NSString*)type;

+ (NSString*)displayNameForActionType:(NSString*)type;

+ (BOOL)isPositiveActionWithType:(NSString*)type;

@end
