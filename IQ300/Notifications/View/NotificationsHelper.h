//
//  NotificationsHelper.h
//  IQ300
//
//  Created by Tayphoon on 02.03.15.
//  Copyright (c) 2015 Tayphoon. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface NotificationsHelper : NSObject

+ (NSString*)displayNameForActionType:(NSString*)type;

+ (BOOL)isPositiveActionWithType:(NSString*)type;

@end
