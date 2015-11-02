//
//  GAIService.h
//  IQ300
//
//  Created by Tayphoon on 18.05.15.
//  Copyright (c) 2015 Tayphoon. All rights reserved.
//

#import <Foundation/Foundation.h>

extern NSString * const GAINotificationsEventCategory;
extern NSString * const GAITasksListEventCategory;
extern NSString * const GAITaskEventCategory;
extern NSString * const GAIMessagesEventCategory;
extern NSString * const GAICommonEventCategory;

extern NSString * const GAIFileUploadEventAction;
extern NSString * const GAICreateMessageEventAction;
extern NSString * const GAIAddConversationMemberEventAction;
extern NSString * const GAIOpenTaskEventAction;
extern NSString * const GAIOpenNotificationEventAction;
extern NSString * const GAIOpenReadedNotificationEventAction;

@interface GAIService : NSObject

+ (void)initializeGoogleAnalytics;

+ (void)sendEventForCategory:(NSString*)eventCategory action:(NSString*)action;

+ (void)sendEventForCategory:(NSString*)eventCategory action:(NSString*)action label:(NSString*)label;

@end
