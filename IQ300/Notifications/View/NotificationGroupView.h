//
//  NotificationGroupView.h
//  IQ300
//
//  Created by Tayphoon on 29.01.15.
//  Copyright (c) 2015 Tayphoon. All rights reserved.
//

#import "NotificationsView.h"
#import "BottomLineView.h"

@interface NotificationGroupView : NotificationsView

@property (nonatomic, readonly) BottomLineView * headerView;
@property (nonatomic, readonly) UIButton * backButton;
@property (nonatomic, readonly) UILabel * titleLabel;

@end
