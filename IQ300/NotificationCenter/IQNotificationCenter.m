//
//  IQNotificationCenter.m
//  IQ300
//
//  Created by Tayphoon on 28.11.14.
//  Copyright (c) 2014 Tayphoon. All rights reserved.
//
#import <Pusher/Pusher.h>
#import <Reachability/Reachability.h>

#import "IQNotificationCenter.h"
#import "DispatchAfterExecution.h"

NSString * const IQNotificationsDidChanged = @"notifications";
NSString * const IQNewMessageNotification = @"comment_created";
NSString * const IQMessageViewedByUserNotification = @"discussion_viewed";
NSString * const IQTasksDidChangedNotification = @"base_tasks";
NSString * const IQTaskDetailsUpdatedNotification = @"task_details_changed";
NSString * const IQTaskCommentsDidChangedNotification = @"task_comments_changed";
NSString * const IQTaskMembersDidChangedNotification = @"task_users_changed";
NSString * const IQTaskAttachmentsDidChangedNotification = @"task_documents_changed";
NSString * const IQNotificationDataKey = @"IQNotificationDataKey";

@class IQCNotification;

@interface IQNotificationObserver : NSObject {
    dispatch_queue_t _queue;
    void(^_dispatchBlock)(IQCNotification * notf);
}

@property (nonatomic, strong) NSString * eventName;

+ (IQNotificationObserver*)observerWithQueue:(dispatch_queue_t)queue dispatchBlock:(void(^)(IQCNotification * notf))dispatchBlock;

- (void)dispatchNotification:(IQCNotification*)notf;

@end

@implementation IQNotificationObserver

+ (IQNotificationObserver*)observerWithQueue:(dispatch_queue_t)queue dispatchBlock:(void (^)(IQCNotification *))dispatchBlock {
    return [[self alloc] initWithQueue:queue dispatchBlock:dispatchBlock];
}

- (instancetype)initWithQueue:(dispatch_queue_t)queue dispatchBlock:(void (^)(IQCNotification *))dispatchBlock {
    self = [super init];
    
    if(self) {
        _queue = queue;
        _dispatchBlock = [dispatchBlock copy];
    }
    
    return self;
}

- (void)dispatchNotification:(IQCNotification*)notf {
    if(_dispatchBlock) {
        dispatch_async(_queue, ^{
            _dispatchBlock(notf);
        });
    }
}

@end

@implementation IQCNotification

+ (instancetype)notificationWithName:(NSString *)aName object:(id)anObject {
    return [IQCNotification notificationWithName:aName object:anObject userInfo:nil];
}

+ (instancetype)notificationWithName:(NSString *)aName object:(id)anObject userInfo:(NSDictionary *)aUserInfo {
    IQCNotification * notf = [[self alloc] initWithName:aName object:anObject userInfo:aUserInfo];
    return notf;
}

- (instancetype)initWithName:(NSString *)name object:(id)object userInfo:(NSDictionary *)userInfo {
    self = [super init];
    
    if(self) {
        _name = [name copy];
        _object = object;
        _userInfo = userInfo;
    }
    
    return self;
}

@end

static IQNotificationCenter * _defaultCenter = nil;

@interface IQNotificationCenter() <PTPusherDelegate> {
    NSString * _defaultChannelName;
    NSMutableDictionary * _channels;
    NSMutableDictionary * _channelBindings;
    NSString * _token;
    NSString * _key;
    UIBackgroundTaskIdentifier _backgroundIdentifier;
    NSMutableDictionary * _observers;
    BOOL _shouldReconnect;
    __weak id _notfObserver;
}

@property (nonatomic, strong) PTPusher * client;

@end

@implementation IQNotificationCenter

+ (instancetype)defaultCenter {
    return _defaultCenter;
}

+ (void)setDefaultCenter:(IQNotificationCenter*)defaultCenter {
    _defaultCenter = defaultCenter;
}

+ (instancetype)centerWithKey:(NSString*)key token:(NSString*)token channelName:(NSString*)channelName {
    IQNotificationCenter * center = [[self alloc] initWithKey:key token:token channelName:channelName];
    if(![self defaultCenter]) {
        [self setDefaultCenter:center];
    }
    return center;
}

- (id)initWithKey:(NSString*)key token:(NSString*)token channelName:(NSString*)channelName {
    self = [super init];
    
    if (self) {
        NSString * authURLString = [NSString stringWithFormat:@"%@/%@", SERVICE_URL, @"api/v1/pusher/auth"];
        
        _key = key;
        _token = token;
        _client = [PTPusher pusherWithKey:key delegate:self encrypted:YES];
        _client.authorizationURL = [NSURL URLWithString:authURLString];
        _shouldReconnect = YES;
        _observers = [NSMutableDictionary dictionary];
        _channels = [NSMutableDictionary dictionary];
        _channelBindings = [NSMutableDictionary dictionary];
        _defaultChannelName = channelName;
        
        __weak typeof (self) weakSelf = self;
        _notfObserver = [[NSNotificationCenter defaultCenter] addObserverForName:PTPusherEventReceivedNotification
                                                                          object:nil
                                                                           queue:nil
                                                                      usingBlock:^(NSNotification *note) {
                                                                          PTPusherEvent * event = note.userInfo[PTPusherEventUserInfoKey];
                                                                           DNSLog(@"[IQNotificationCenter-%@] Received event named %@ data:%@",
                                                                                  weakSelf.client.connection.socketID,
                                                                                  event.name,
                                                                                  event.data);

                                                                          if(event && note.object == weakSelf.client) {
                                                                              [weakSelf pusher:weakSelf.client didReceiveEvent:event];
                                                                          }
                                                                      }];

        if(channelName) {
            PTPusherChannel * channel = [_client subscribeToChannelNamed:channelName];
            _channels[channelName] = channel;
        }
                
        [_client connect];
        
        [[NSNotificationCenter defaultCenter] addObserver:self
                                                 selector:@selector(disconnect)
                                                     name:UIApplicationDidEnterBackgroundNotification
                                                   object:nil];
        
        [[NSNotificationCenter defaultCenter] addObserver:self
                                                 selector:@selector(reconnect)
                                                     name:UIApplicationWillEnterForegroundNotification
                                                   object:nil];
    }
    
    return self;
}

- (id<NSObject>)addObserverForName:(NSString *)name queue:(dispatch_queue_t)queue usingBlock:(void (^)(IQCNotification * notf))block {
    return [self addObserverForName:name channelName:_defaultChannelName queue:queue usingBlock:block];
}

- (id<NSObject>)addObserverForName:(NSString *)name channelName:(NSString*)channelName queue:(dispatch_queue_t)queue usingBlock:(void (^)(IQCNotification * notf))block {
    NSParameterAssert(block);
    
    DNSLog(@"Add observer for channel %@ eventName %@", channelName, name);

    dispatch_queue_t dispatchQueue = (queue) ? queue : dispatch_get_main_queue();
    IQNotificationObserver * observer = [IQNotificationObserver observerWithQueue:dispatchQueue dispatchBlock:block];
    observer.eventName = name;
    [self addObserver:observer forChannel:channelName forEventName:name];
    [self subscribeChannelWithName:channelName toEventNamed:name];
    return observer;
}


- (void)removeObserver:(id)observer {
    if (observer) {
        [self removeObserver:observer name:nil];
    }
}

- (void)removeObserver:(id)observer name:(NSString *)name {
    [self removeObserver:observer name:name channelName:_defaultChannelName];
}

- (void)removeObserver:(id)observer name:(NSString *)eventName channelName:(NSString*)channelName {
    NSString * key = [NSString stringWithFormat:@"%@_%@", channelName, eventName];
    
    if ([eventName length] > 0) {
        NSMutableArray * observers = _observers[key];
        if([observers containsObject:observer]) {
            [observers removeObject:observer];
            [self unsubscribeChannelWithName:channelName toEventNamed:eventName];
        }
    }
    else {
        for (NSString * observerKey in [_observers allKeys]) {
            NSMutableArray * observers = _observers[observerKey];
            if([observers containsObject:observer]) {
                [observers removeObject:observer];
                eventName = ([observer respondsToSelector:@selector(eventName)]) ? [observer valueForKey:@"eventName"] : nil;
                if([eventName length] > 0 && [observers count] == 0) {
                    [self unsubscribeChannelWithName:channelName toEventNamed:eventName];
                }
            }
        }
    }
}

- (void)resetAllObservers {
    [_observers removeAllObjects];
    
    for (PTPusherChannel * channel in [_channels allValues]) {
        [channel unsubscribe];
    }
    
    [_channels removeAllObjects];
    [_channelBindings removeAllObjects];
}

- (void)dealloc {
    [[NSNotificationCenter defaultCenter] removeObserver:_notfObserver];
    [[NSNotificationCenter defaultCenter] removeObserver:self];
    
    _client.delegate = nil;
    [_client disconnect];
    _client = nil;
}

#pragma mark - Private methods

- (void)subscribeChannelWithName:(NSString*)channelName toEventNamed:(NSString*)eventName {
    NSString * key = [NSString stringWithFormat:@"%@_%@", channelName, eventName];
    DNSLog(@"Subscribe channel %@ event %@", channelName, eventName);
    PTPusherChannel * channel = _channels[channelName];
    if(!channel) {
        channel = [_client subscribeToChannelNamed:channelName];
        _channels[channelName] = channel;
    }
    
    if(!_channelBindings[key]) {
        PTPusherEventBinding * binding = [channel bindToEventNamed:eventName handleWithBlock:^(PTPusherEvent *channelEvent) {
            DNSLog(@"*************************************");
            DNSLog(@"Recive event named %@ from channel %@", eventName, channelName);
            DNSLog(@"*************************************");
        }];
        
        _channelBindings[key] = binding;
    }
}

- (void)unsubscribeChannelWithName:(NSString*)channelName toEventNamed:(NSString*)eventName {
    NSString * key = [NSString stringWithFormat:@"%@_%@", channelName, eventName];
    DNSLog(@"Unsubscribe channel %@ event %@", channelName, eventName);
    PTPusherChannel * channel = _channels[channelName];
    
    if(_channelBindings[key]) {
        PTPusherEventBinding * binding = _channelBindings[key];
        [channel removeBinding:binding];
        [_channelBindings removeObjectForKey:eventName];
    }
}

- (void)reconnect {
    dispatch_after_delay(1, dispatch_get_main_queue(), ^{
        NSInteger connectionState = [[_client.connection valueForKey:@"state"] integerValue];
        if(connectionState < PTPusherConnectionConnecting) {
            _shouldReconnect = YES;
            [_client connect];
        }
    });
}

- (void)disconnect {
    [self beginBackgroundDisconnectTaskWithBlock:^{
        dispatch_async(dispatch_get_main_queue(), ^{
            _shouldReconnect = NO;
            [_client disconnect];
        });
    }];
}

- (void)beginBackgroundDisconnectTaskWithBlock:(void(^)(void))backgroundBlock  {
    if(backgroundBlock) {
        dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
            _backgroundIdentifier = [[UIApplication sharedApplication] beginBackgroundTaskWithExpirationHandler:^{
                [self endBackgroundDisconnectTask];
            }];
            backgroundBlock();
        });
    }
}

- (void)endBackgroundDisconnectTask {
    [[UIApplication sharedApplication] endBackgroundTask:_backgroundIdentifier];
    _backgroundIdentifier = UIBackgroundTaskInvalid;
}

#pragma mark - Dispatch Notifications

- (void)addObserver:(IQNotificationObserver*)observer forChannel:(NSString*)channelName forEventName:(NSString*)eventName {
    NSString * key = [NSString stringWithFormat:@"%@_%@", channelName, eventName];
    NSMutableArray * observers = _observers[key];

    if(!observers) {
        observers = [NSMutableArray array];
        _observers[key] = observers;
    }
    
    [observers addObject:observer];
}

- (void)dispatchNotification:(IQCNotification*)notf formChannel:(NSString*)channelName {
    NSString * key = [NSString stringWithFormat:@"%@_%@", channelName, notf.name];
    NSArray * observers = _observers[key];
    DNSLog(@"%s notification key %@", __PRETTY_FUNCTION__, key);
    
    for (IQNotificationObserver * observer in observers) {
        [observer dispatchNotification:notf];
        DNSLog(@"Found observer %@", observer);
    }
}

#pragma mark - Reachability

- (void)startReachabilityCheck {
    // we probably have no internet connection, so lets check with Reachability
    Reachability *reachability = [Reachability reachabilityWithHostname:_client.connection.URL.host];
    
    if ([reachability isReachable]) {
        // we appear to have a connection, so something else must have gone wrong
        DNSLog(@"Internet reachable, reconnecting");
        [_client connect];
    }
    else {
        DNSLog(@"Waiting for reachability");
        
        [reachability setReachableBlock:^(Reachability *reachability) {
            if ([reachability isReachable]) {
                DNSLog(@"Internet is now reachable");
                [reachability stopNotifier];
                
                dispatch_async(dispatch_get_main_queue(), ^{
                    [_client connect];
                });
            }
        }];
        
        [reachability startNotifier];
    }
}

#pragma mark - PTPusherDelegate methods

- (BOOL)pusher:(PTPusher *)pusher connectionWillConnect:(PTPusherConnection *)connection {
    DNSLog(@"[IQNotificationCenter] Pusher client connecting...");
    return YES;
}

- (void)pusher:(PTPusher *)pusher connectionDidConnect:(PTPusherConnection *)connection {
    DNSLog(@"[IQNotificationCenter-%@] Pusher client connected", connection.socketID);
}

- (void)pusher:(PTPusher *)pusher connection:(PTPusherConnection *)connection failedWithError:(NSError *)error {
    DNSLog(@"[IQNotificationCenter] Pusher Connection failed with error: %@", error);
    if ([error.domain isEqualToString:(NSString *)kCFErrorDomainCFNetwork]) {
        [self startReachabilityCheck];
    }
}

- (void)pusher:(PTPusher *)pusher connection:(PTPusherConnection *)connection didDisconnectWithError:(NSError *)error willAttemptReconnect:(BOOL)willAttemptReconnect {
    DNSLog(@"[IQNotificationCenter-%@] Pusher Connection disconnected with error: %@", pusher.connection.socketID, error);
    
    if (willAttemptReconnect) {
        DNSLog(@"[IQNotificationCenter-%@] Client will attempt to reconnect automatically", pusher.connection.socketID);
    }
    else {
        if (![error.domain isEqualToString:PTPusherErrorDomain]) {
            [self startReachabilityCheck];
        }
    }
    
    if(_backgroundIdentifier != UIBackgroundTaskInvalid) {
        [self endBackgroundDisconnectTask];
    }
}

- (BOOL)pusher:(PTPusher *)pusher connectionWillAutomaticallyReconnect:(PTPusherConnection *)connection afterDelay:(NSTimeInterval)delay {
    if(_shouldReconnect) {
        DNSLog(@"[IQNotificationCenter-%@] Client automatically reconnecting after %d seconds...", pusher.connection.socketID, (int)delay);
    }
    return _shouldReconnect;
}

- (void)pusher:(PTPusher *)pusher didSubscribeToChannel:(PTPusherChannel *)channel {
    DNSLog(@"[IQNotificationCenter-%@] Subscribed to channel %@", pusher.connection.socketID, channel);
}

- (void)pusher:(PTPusher *)pusher didFailToSubscribeToChannel:(PTPusherChannel *)channel withError:(NSError *)error {
    DNSLog(@"[IQNotificationCenter-%@] Authorization failed for channel %@", pusher.connection.socketID, channel);
    
}

- (void)pusher:(PTPusher *)pusher didReceiveErrorEvent:(PTPusherErrorEvent *)errorEvent {
    DNSLog(@"[IQNotificationCenter-%@] Received error event %@", pusher.connection.socketID, errorEvent);
}

/* The app uses HTTP basic authentication.
 
 This demonstrates how we can intercept the authorization request to configure it for our app's
 authentication/authorisation needs.
 */
- (void)pusher:(PTPusher *)pusher willAuthorizeChannel:(PTPusherChannel *)channel withRequest:(NSMutableURLRequest *)request {
    DNSLog(@"[IQNotificationCenter-%@] Authorizing channel access...", pusher.connection.socketID);
    [request setValue:_token forHTTPHeaderField:@"Authorization"];
}

- (void)pusher:(PTPusher *)pusher didReceiveEvent:(PTPusherEvent *)event {
    DNSLog(@"[IQNotificationCenter-%@] Received event named %@ data:%@", pusher.connection.socketID, event.name, event.data);
    IQCNotification * notf = [[IQCNotification alloc] initWithName:event.name
                                                            object:self
                                                          userInfo:@{ IQNotificationDataKey : event.data }];
    [self dispatchNotification:notf formChannel:event.channel];
}

@end
