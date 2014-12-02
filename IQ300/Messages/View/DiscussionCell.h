//
//  ConversationCell.h
//  IQ300
//
//  Created by Tayphoon on 02.12.14.
//  Copyright (c) 2014 Tayphoon. All rights reserved.
//

#import <UIKit/UIKit.h>

@class CustomBadge;
@class IQDiscussion;

@interface DiscussionCell : UITableViewCell {
    UIEdgeInsets _contentInsets;
    UIEdgeInsets _contentBackgroundInsets;
}

@property (nonatomic, strong) UIView * contentBackgroundView;
@property (nonatomic, strong) UILabel * dateLabel;
@property (nonatomic, strong) UILabel * userNameLabel;
@property (nonatomic, strong) UILabel * descriptionLabel;
@property (nonatomic, readonly) CustomBadge * badgeView;

@property (nonatomic, strong) IQDiscussion * item;

@end
