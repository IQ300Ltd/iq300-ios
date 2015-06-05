//
//  Notifications].h
//  IQ300
//
//  Created by Tayphoon on 21.11.14.
//  Copyright (c) 2014 Tayphoon. All rights reserved.
//

#import <SWTableViewCell/SWTableViewCell.h>

#define READ_FLAG_WIDTH 4.0f
#define READ_FLAG_COLOR [UIColor colorWithHexInt:0x005275]
#define CONTEN_BACKGROUND_COLOR [UIColor colorWithHexInt:0xe9faff]
#define CONTEN_BACKGROUND_COLOR_R [UIColor whiteColor]
#define NOTIFICATION_CELL_MAX_HEIGHT 105.0f
#define NOTIFICATION_CELL_MIN_HEIGHT 76.0f

@class IQNotification;

@interface NotificationCell : SWTableViewCell {
    UIEdgeInsets _contentInsets;
    UIEdgeInsets _contentBackgroundInsets;
}

@property (nonatomic, strong) UIView * contentBackgroundView;
@property (nonatomic, strong) UILabel * dateLabel;
@property (nonatomic, strong) UILabel * userNameLabel;
@property (nonatomic, strong) UILabel * actionLabel;
@property (nonatomic, strong) UILabel * descriptionLabel;
@property (nonatomic, strong) UIButton * markAsReadedButton;

@property (nonatomic, strong) IQNotification * item;

+ (CGFloat)heightForItem:(IQNotification *)item andCellWidth:(CGFloat)cellWidth;

@end
