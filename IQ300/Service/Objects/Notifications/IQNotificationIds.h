//
//  IQNotificationIds.h
//  IQ300
//
//  Created by Tayphoon on 16.01.15.
//  Copyright (c) 2015 Tayphoon. All rights reserved.
//

#import <Foundation/Foundation.h>

@class RKObjectMapping;

@interface IQNotificationIds : NSObject

@property (nonatomic, strong) NSArray * notificationIds;

+ (RKObjectMapping*)objectMapping;

@end
