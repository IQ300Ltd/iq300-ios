//
//  TaskActivitiesModel.h
//  IQ300
//
//  Created by Tayphoon on 01.04.15.
//  Copyright (c) 2015 Tayphoon. All rights reserved.
//

#import "IQTableModel.h"

@interface TaskActivitiesModel : NSObject<IQTableModel>

@property (nonatomic, readonly) NSString * category;

@property (nonatomic, strong) NSNumber * taskId;
@property (nonatomic, strong) NSNumber * unreadCount;
@property (nonatomic, assign) CGFloat cellWidth;
@property (nonatomic, assign) BOOL resetReadFlagAutomatically;

@property (nonatomic, weak) id<IQTableModelDelegate> delegate;

- (void)loadNextPartWithCompletion:(void (^)(NSError * error))completion;

- (void)resetReadFlagWithCompletion:(void (^)(NSError * error))completion;

- (void)setSubscribedToNotifications:(BOOL)subscribed;

@end
