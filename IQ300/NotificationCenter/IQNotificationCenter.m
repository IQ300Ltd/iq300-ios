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

static IQNotificationCenter * _defaultCenter = nil;

@interface IQNotificationCenter() <PTPusherDelegate> {
    PTPusher * _client;
    PTPusherChannel * _channel;
    NSString * _token;
    NSString * _key;
    NSString * _channelName;
}

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
        _channelName = channelName;
        _client = [PTPusher pusherWithKey:key delegate:self encrypted:YES];
        _client.authorizationURL = [NSURL URLWithString:authURLString];
        
#ifdef kLOG_ALL_EVENTS
        __weak typeof (self) weakSelf = self;
        [[NSNotificationCenter defaultCenter] addObserverForName:PTPusherEventReceivedNotification
                                                          object:nil
                                                           queue:nil
                                                      usingBlock:^(NSNotification *note) {
                                                         PTPusherEvent * event = note.userInfo[PTPusherEventUserInfoKey];
                                                          if(event) {
                                                              [weakSelf pusher:_client didReceiveEvent:event];
                                                          }
                                                      }];
#endif

        _channel = [_client subscribeToChannelNamed:_channelName];
        [_channel bindToEventNamed:@"notifications" handleWithBlock:^(PTPusherEvent *channelEvent) {
            DNSLog(@"[IQNotificationCenter] Received notification data:%@", channelEvent.data);
        }];
        [_client connect];
    }
    
    return self;
}

- (void)dealloc {
    [[NSNotificationCenter defaultCenter] removeObserver:self];
    _client.delegate = nil;
    [_client disconnect];
    _client = nil;
}

#pragma mark - Private methods

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

- (void)pusher:(PTPusher *)pusher connection:(PTPusherConnection *)connection failedWithError:(NSError *)error
{
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
}

- (BOOL)pusher:(PTPusher *)pusher connectionWillAutomaticallyReconnect:(PTPusherConnection *)connection afterDelay:(NSTimeInterval)delay {
    DNSLog(@"[IQNotificationCenter-%@] Client automatically reconnecting after %d seconds...", pusher.connection.socketID, (int)delay);
    return YES;
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
}

@end
