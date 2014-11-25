//
//  IQService.h
//  IQ300
//
//  Created by Tayphoon on 13.11.14.
//  Copyright (c) 2014 Tayphoon. All rights reserved.
//

#import "TCService+Subclass.h"
#import "IQSession.h"

#define SERVICE_REGISTRATION_URL [NSString stringWithFormat:@"%@/%@", SERVICE_URL, @"users/sign_up"]
#define SERVICE_RESET_PASSWORD_URL [NSString stringWithFormat:@"%@/%@", SERVICE_URL, @"users/password/new"]

@interface IQService : TCService

@property (nonatomic, strong) IQSession * session;

- (void)loginWithEmail:(NSString*)email password:(NSString*)password handler:(RequestCompletionHandler)handler;
- (void)logout;

- (void)userInfoWithHandler:(ObjectLoaderCompletionHandler)handler;

/**
 Request user notifications. There is an opportunity to receive notifications portions.
 
 @param unread If flag i set return only unread notifications(optional).
 @param page Serial number of portions(optional).
 @param per Portion size(optional).
 @param search Search text using as filter(optional).
 @param handler Handler block. Look `ObjectLoaderCompletionHandler`.
 */
- (void)notificationsUnread:(NSNumber*)unread page:(NSNumber*)page per:(NSNumber*)per search:(NSString*)search handler:(ObjectLoaderCompletionHandler)handler;

@end
