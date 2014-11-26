//
//  NotificationsCount.h
//  IQ300
//
//  Created by Tayphoon on 26.11.14.
//  Copyright (c) 2014 Tayphoon. All rights reserved.
//

#import <Foundation/Foundation.h>

@class RKObjectMapping;

@interface NotificationsCount : NSObject

@property (nonatomic, strong) NSNumber * totalCount;
@property (nonatomic, strong) NSNumber * unreadCount;

+ (RKObjectMapping*)objectMapping;

@end
