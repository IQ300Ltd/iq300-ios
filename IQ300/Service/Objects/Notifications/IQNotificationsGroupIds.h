//
//  IQNotificationsGroupIds.h
//  IQ300
//
//  Created by Tayphoon on 18.02.15.
//  Copyright (c) 2015 Tayphoon. All rights reserved.
//

#import <Foundation/Foundation.h>

@class RKObjectMapping;

@interface IQNotificationsGroupIds : NSObject

@property (nonatomic, strong) NSArray * groupIds;

+ (RKObjectMapping*)objectMapping;

@end
