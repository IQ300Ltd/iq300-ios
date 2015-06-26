//
//  FeedbacksModel.h
//  IQ300
//
//  Created by Tayphoon on 23.06.15.
//  Copyright (c) 2015 Tayphoon. All rights reserved.
//

#import "IQTableManagedModel.h"

@interface FeedbacksModel : IQTableManagedModel

@property (nonatomic, assign) CGFloat cellWidth;
@property (nonatomic, strong) NSString * search;

- (void)loadNextPartWithCompletion:(void (^)(NSError * error))completion;

- (void)setSubscribedToNotifications:(BOOL)subscribed;

@end
