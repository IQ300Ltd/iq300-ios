//
//  NotificationsModelDelegate.h
//  IQ300
//
//  Created by Tayphoon on 02.12.14.
//  Copyright (c) 2014 Tayphoon. All rights reserved.
//

#import "IQTableModel.h"

@protocol NotificationsModelDelegate <IQTableModelDelegate>

@optional

- (void)modelCountersDidChanged:(id<IQTableModel>)model;

@end
