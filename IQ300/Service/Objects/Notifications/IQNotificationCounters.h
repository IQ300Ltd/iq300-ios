//
//  IQNotificationsCounter.h
//  IQ300
//
//  Created by Tayphoon on 03.02.16.
//  Copyright © 2016 Tayphoon. All rights reserved.
//

#import <Foundation/Foundation.h>

@class RKObjectMapping;

@interface IQNotificationCounters : NSObject

@property (nonatomic, strong) NSNumber * pinnedCount;
@property (nonatomic, strong) NSNumber * unreadCount;

+ (RKObjectMapping*)objectMapping;

@end
