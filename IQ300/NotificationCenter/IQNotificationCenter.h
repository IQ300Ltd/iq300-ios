//
//  IQNotificationCenter.h
//  IQ300
//
//  Created by Tayphoon on 28.11.14.
//  Copyright (c) 2014 Tayphoon. All rights reserved.
//

#import <Foundation/Foundation.h>

//#define kLOG_ALL_EVENTS
//#define kLOG_TRACE

#ifdef kLOG_TRACE
#define DNSLog(x, ...) NSLog(@"%s %d: " x, __FUNCTION__, __LINE__, ##__VA_ARGS__)
#else
#define DNSLog(x, ...)
#endif


extern NSString * const IQNotificationsDidChanged;
extern NSString * const IQNotificationDataKey;

@interface IQCNotification : NSObject

@property (readonly, copy) NSString *name;
@property (readonly, retain) id object;
@property (readonly, copy) NSDictionary *userInfo;

- (instancetype)initWithName:(NSString *)name object:(id)object userInfo:(NSDictionary *)userInfo;

@end

@interface IQCNotification (IQNotificationCreation)

+ (instancetype)notificationWithName:(NSString *)aName object:(id)anObject;
+ (instancetype)notificationWithName:(NSString *)aName object:(id)anObject userInfo:(NSDictionary *)aUserInfo;

@end

@interface IQNotificationCenter : NSObject

+ (instancetype)defaultCenter;
+ (void)setDefaultCenter:(IQNotificationCenter*)defaultCenter;

+ (instancetype)centerWithKey:(NSString*)key token:(NSString*)token channelName:(NSString*)channelName;

- (id)initWithKey:(NSString*)key token:(NSString*)token channelName:(NSString*)channelName;

- (void)addObserverForName:(NSString *)name queue:(dispatch_queue_t)queue usingBlock:(void (^)(IQCNotification * note))block;

- (void)removeObserver:(id)observer;
- (void)removeObserver:(id)observer name:(NSString *)aName;

@end
