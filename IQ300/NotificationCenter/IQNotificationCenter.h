//
//  IQNotificationCenter.h
//  IQ300
//
//  Created by Tayphoon on 28.11.14.
//  Copyright (c) 2014 Tayphoon. All rights reserved.
//

#import <Foundation/Foundation.h>

#define kLOG_ALL_EVENTS
#ifdef DEBUG
#define DNSLog(x, ...) NSLog(@"%s %d: " x, __FUNCTION__, __LINE__, ##__VA_ARGS__)
#else
#define DNSLog(x, ...)
#endif

@interface IQNotificationCenter : NSObject

+ (instancetype)defaultCenter;
+ (void)setDefaultCenter:(IQNotificationCenter*)defaultCenter;

+ (instancetype)centerWithKey:(NSString*)key token:(NSString*)token channelName:(NSString*)channelName;

- (id)initWithKey:(NSString*)key token:(NSString*)token channelName:(NSString*)channelName;

@end
