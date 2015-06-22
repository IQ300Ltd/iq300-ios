//
//  NGroupCell.h
//  IQ300
//
//  Created by Tayphoon on 28.01.15.
//  Copyright (c) 2015 Tayphoon. All rights reserved.
//

#import <SWTableViewCell/SWTableViewCell.h>

#define READ_FLAG_WIDTH 4.0f
#define READ_FLAG_COLOR [UIColor colorWithHexInt:0x005275]
#define CONTEN_BACKGROUND_COLOR [UIColor colorWithHexInt:0xe9faff]
#define CONTEN_BACKGROUND_COLOR_R [UIColor whiteColor]

@class IQNotificationsGroup;
@class IQBadgeView;

@interface NGroupCell : SWTableViewCell {
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
@property (nonatomic, strong) UIButton * markAsReadedButton;
@property (nonatomic, readonly) IQBadgeView * badgeView;
@property (nonatomic, assign) BOOL showUnreadOnly;

@property (nonatomic, strong) IQNotificationsGroup * item;

+ (CGFloat)heightForItem:(IQNotificationsGroup *)item andCellWidth:(CGFloat)cellWidth showUnreadOnly:(BOOL)showUnreadOnly;

@end
