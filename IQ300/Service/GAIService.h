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

@interface GAIService : NSObject

+ (void)initializeGoogleAnalytics;

+ (void)sendEventForCategory:(NSString*)eventCategory action:(NSString*)action;

@end
