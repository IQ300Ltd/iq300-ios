//
//  Notifications].h
//  IQ300
//
//  Created by Tayphoon on 21.11.14.
//  Copyright (c) 2014 Tayphoon. All rights reserved.
//

#import <UIKit/UIKit.h>

@class IQNotification;

@interface NotificationCell : UITableViewCell {
    UIEdgeInsets _contentInsets;
    UIEdgeInsets _contentBackgroundInsets;
}

@property (nonatomic, strong) UIView * contentBackgroundView;
@property (nonatomic, strong) UILabel * typeLabel;
@property (nonatomic, strong) UILabel * dateLabel;
@property (nonatomic, strong) UILabel * titleLabel;
@property (nonatomic, strong) UILabel * userNameLabel;
@property (nonatomic, strong) UILabel * actionLabel;
@property (nonatomic, strong) UILabel * descriptionLabel;

@property (nonatomic, strong) IQNotification * item;

@end
