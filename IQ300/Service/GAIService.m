//
//  GAIService.m
//  IQ300
//
//  Created by Tayphoon on 18.05.15.
//  Copyright (c) 2015 Tayphoon. All rights reserved.
//
#import <GoogleAnalytics-iOS-SDK/GAI.h>
#import <GoogleAnalytics-iOS-SDK/GAIDictionaryBuilder.h>

#import "GAIService.h"

NSString * const GAINotificationsEventCategory = @"event_group_notification";
NSString * const GAITasksListEventCategory = @"event_group_tasks_list";
NSString * const GAITaskEventCategory = @"event_group_task";
NSString * const GAIMessagesEventCategory = @"event_group_message";
NSString * const GAICommonEventCategory = @"event_group_common";

NSString * const GAIFileUploadEventAction = @"event_action_common_file_upload";
NSString * const GAICreateMessageEventAction = @"event_action_message_create";

@implementation GAIService

+ (void)initializeGoogleAnalytics {
    [GAI sharedInstance].dispatchInterval = 20;
    [[GAI sharedInstance] trackerWithTrackingId:@"UA-62928896-1"];
}

+ (void)sendEventForCategory:(NSString*)eventCategory action:(NSString*)action {
    id<GAITracker> tracker = [[GAI sharedInstance] defaultTracker];
    
    [tracker send:[[GAIDictionaryBuilder createEventWithCategory:eventCategory
                                                          action:action
                                                           label:nil
                                                           value:nil] build]];
}

@end
