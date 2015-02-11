//
//  NGroupCell.m
//  IQ300
//
//  Created by Tayphoon on 28.01.15.
//  Copyright (c) 2015 Tayphoon. All rights reserved.
//
#import <QuartzCore/QuartzCore.h>

#import "NGroupCell.h"
#import "IQNotificationsGroup.h"
#import "NSDate+IQFormater.h"
#import "IQBadgeView.h"
#import "IQNotification.h"

#define HORIZONTAL_INSETS 8.0f
#define VERTICAL_INSETS 5.0f
#define DESCRIPTION_FONT [UIFont fontWithName:IQ_HELVETICA size:13]
#define DESCRIPTION_MIN_HEIGHT 19.0f

@implementation NGroupCell

+ (CGFloat)heightForItem:(IQNotificationsGroup *)item andCellWidth:(CGFloat)cellWidth {
    CGFloat width = cellWidth - HORIZONTAL_INSETS * 2.0f - 40;
    CGFloat height = GROUP_CELL_MIN_HEIGHT - DESCRIPTION_MIN_HEIGHT;
    
    if([item.lastNotification.additionalDescription length] > 0) {
        CGSize constrainedSize = CGSizeMake(width,
                                            GROUP_CELL_MAX_HEIGHT);
        
        CGSize desSize = [item.lastNotification.additionalDescription sizeWithFont:DESCRIPTION_FONT
                                         constrainedToSize:constrainedSize
                                             lineBreakMode:NSLineBreakByWordWrapping];
        height = MAX(height + desSize.height, height);
    }
    
    return height;
}

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier {
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    
    if(self) {
        UIView * contentView = [super valueForKey:@"_contentCellView"];
        self.selectionStyle = UITableViewCellSelectionStyleNone;
        
        _markAsReadedButton = [[UIButton alloc] init];
        [_markAsReadedButton setBackgroundColor:[UIColor colorWithHexInt:0x005275]];
        [_markAsReadedButton setImage:[UIImage imageNamed:@"check_mark_medium"] forState:UIControlStateNormal];
        
        _contentInsets = UIEdgeInsetsMake(VERTICAL_INSETS, HORIZONTAL_INSETS, VERTICAL_INSETS, HORIZONTAL_INSETS);
        _contentBackgroundInsets = UIEdgeInsetsZero;
        
        [self setBackgroundColor:READ_FLAG_COLOR];
        
        _contentBackgroundView = [[UIView alloc] init];
        _contentBackgroundView.backgroundColor = CONTEN_BACKGROUND_COLOR;
        [contentView addSubview:_contentBackgroundView];
        
        _typeLabel = [self makeLabelWithTextColor:[UIColor colorWithHexInt:0xb3b3b3]
                                             font:[UIFont fontWithName:IQ_HELVETICA size:13]
                                    localaizedKey:@"Project"];
        [contentView addSubview:_typeLabel];
        
        _dateLabel = [self makeLabelWithTextColor:[UIColor colorWithHexInt:0xb3b3b3]
                                             font:[UIFont fontWithName:IQ_HELVETICA size:13]
                                    localaizedKey:nil];
        _dateLabel.textAlignment = NSTextAlignmentRight;
        [contentView addSubview:_dateLabel];
        
        _titleLabel = [self makeLabelWithTextColor:[UIColor colorWithHexInt:0x272727]
                                              font:[UIFont fontWithName:IQ_HELVETICA size:13]
                                     localaizedKey:nil];
        _titleLabel.lineBreakMode = NSLineBreakByTruncatingTail;
        [contentView addSubview:_titleLabel];
        
        _userNameLabel = [self makeLabelWithTextColor:[UIColor whiteColor]
                                                 font:[UIFont fontWithName:IQ_HELVETICA size:13]
                                        localaizedKey:nil];
        _userNameLabel.backgroundColor = [UIColor colorWithHexInt:0xcccccc];
        _userNameLabel.layer.cornerRadius = 3;
        _userNameLabel.textAlignment = NSTextAlignmentCenter;
        _userNameLabel.clipsToBounds = YES;
        [contentView addSubview:_userNameLabel];
        
        _actionLabel = [self makeLabelWithTextColor:[UIColor colorWithHexInt:0x272727]
                                               font:[UIFont fontWithName:IQ_HELVETICA size:13]
                                      localaizedKey:nil];
        _actionLabel.lineBreakMode = NSLineBreakByTruncatingTail;
        [contentView addSubview:_actionLabel];
        
        _descriptionLabel = [self makeLabelWithTextColor:[UIColor colorWithHexInt:0x9b9c9e]
                                                    font:[UIFont fontWithName:IQ_HELVETICA size:13]
                                           localaizedKey:nil];
        _descriptionLabel.lineBreakMode = NSLineBreakByTruncatingTail;
        [contentView addSubview:_descriptionLabel];
        
        IQBadgeStyle * style = [IQBadgeStyle defaultStyle];
        style.badgeTextColor = [UIColor whiteColor];
        style.badgeInsetColor = [UIColor colorWithHexInt:0x338cae];
        
        _badgeView = [IQBadgeView customBadgeWithString:nil withStyle:style];
        _badgeView.badgeMinSize = 17;
        _badgeView.badgeTextFont = [UIFont fontWithName:IQ_HELVETICA size:10];
        [_badgeView setHidden:YES];
        [contentView addSubview:_badgeView];

    }
    
    return self;
}

- (void)layoutSubviews {
    [super layoutSubviews];
    
    IQNotification * notification = _item.lastNotification;
    CGRect bounds = self.contentView.bounds;
    CGRect actualBounds = UIEdgeInsetsInsetRect(bounds, _contentInsets);
    CGFloat labelsOffset = 5.0f;
    
    CGRect contentBackgroundBounds = UIEdgeInsetsInsetRect(bounds, _contentBackgroundInsets);
    _contentBackgroundView.frame = contentBackgroundBounds;
    
    CGSize topLabelSize = CGSizeMake(actualBounds.size.width / 2.0f, 14);
    _typeLabel.frame = CGRectMake(actualBounds.origin.x + labelsOffset,
                                  actualBounds.origin.y,
                                  topLabelSize.width,
                                  topLabelSize.height);
    
    _dateLabel.frame = CGRectMake(actualBounds.origin.x + actualBounds.size.width - topLabelSize.width,
                                  actualBounds.origin.y,
                                  topLabelSize.width,
                                  topLabelSize.height);
    
    _badgeView.frame = CGRectMake(actualBounds.origin.x + actualBounds.size.width - _badgeView.frame.size.width,
                                  _titleLabel.frame.origin.y,
                                  _badgeView.frame.size.width,
                                  _badgeView.frame.size.height);
    
    _titleLabel.frame = CGRectMake(actualBounds.origin.x + labelsOffset,
                                   _typeLabel.frame.origin.y + _typeLabel.frame.size.height + 4,
                                   actualBounds.size.width - _badgeView.frame.size.width - 5.0f,
                                   16);
    
    CGFloat userNameHeight = 17;
    CGFloat userNameMaxWidth = actualBounds.size.width / 2.0f;
    CGSize constrainedSize = CGSizeMake(userNameMaxWidth,
                                        userNameHeight);
    
    CGPoint actionLabelLocation = CGPointMake(actualBounds.origin.x, CGRectBottom(_titleLabel.frame) + 5);
    if (([notification.user.displayName length] > 0)) {
        CGSize userSize = [_userNameLabel.text sizeWithFont:_userNameLabel.font
                                          constrainedToSize:constrainedSize
                                              lineBreakMode:_userNameLabel.lineBreakMode];
        
        _userNameLabel.frame = CGRectMake(actualBounds.origin.x,
                                          CGRectBottom(_titleLabel.frame) + 5,
                                          userSize.width + 5,
                                          userNameHeight);
        actionLabelLocation = CGPointMake(CGRectRight(_userNameLabel.frame) + 5, _userNameLabel.frame.origin.y);
    }
    else {
        _userNameLabel.frame = CGRectZero;
        actionLabelLocation = CGPointMake(actualBounds.origin.x, CGRectBottom(_titleLabel.frame) + 5);
    }
    
    
    _actionLabel.frame = CGRectMake(actionLabelLocation.x + labelsOffset,
                                    actionLabelLocation.y,
                                    actualBounds.size.width - actionLabelLocation.x,
                                    userNameHeight);
    
    CGFloat descriptionY = CGRectBottom(_actionLabel.frame) + 2.0f;
    _descriptionLabel.frame = CGRectMake(actualBounds.origin.x + labelsOffset,
                                         descriptionY,
                                         actualBounds.size.width - 40.0f,
                                         actualBounds.size.height - descriptionY);
}

- (void)setItem:(IQNotificationsGroup *)item {
    _item = item;
    
    IQNotification * notification = _item.lastNotification;
    BOOL isReaded = ([_item.unreadCount integerValue] == 0);
    _contentBackgroundInsets = (isReaded) ? UIEdgeInsetsZero : UIEdgeInsetsMake(0, READ_FLAG_WIDTH, 0, 0);
    _contentBackgroundView.backgroundColor = (isReaded) ? CONTEN_BACKGROUND_COLOR_R :
    CONTEN_BACKGROUND_COLOR;
    self.rightUtilityButtons = (isReaded) ? nil : @[_markAsReadedButton];
    
    if(!isReaded) {
        NSInteger badgeValue = [_item.unreadCount integerValue];
        _badgeView.badgeValue = (badgeValue > 99.0f) ? @"99+" : [_item.unreadCount stringValue];
        _badgeView.hidden = NO;
    }
    
    _typeLabel.text = NSLocalizedString(notification.notificable.type, nil);
    _dateLabel.text = [notification.createdAt dateToDayTimeString];
    _titleLabel.text = notification.notificable.title;
    _userNameLabel.hidden = ([notification.user.displayName length] == 0);
    _userNameLabel.text = notification.user.displayName;
    _actionLabel.text = notification.mainDescription;
    _descriptionLabel.text = notification.additionalDescription;
    [self setNeedsLayout];
}

- (void)prepareForReuse {
    [super prepareForReuse];
    
    _badgeView.hidden = YES;
    _contentBackgroundInsets = UIEdgeInsetsZero;
    _contentBackgroundView.backgroundColor = CONTEN_BACKGROUND_COLOR_R;
    [self hideUtilityButtonsAnimated:NO];
}

- (UILabel*)makeLabelWithTextColor:(UIColor*)textColor font:(UIFont*)font localaizedKey:(NSString*)localaizedKey {
    UILabel * label = [[UILabel alloc] init];
    [label setFont:font];
    [label setTextColor:textColor];
    label.textAlignment = NSTextAlignmentLeft;
    label.backgroundColor = [UIColor clearColor];
    label.numberOfLines = 0;
    label.lineBreakMode = NSLineBreakByWordWrapping;
    if(localaizedKey) {
        [label setText:NSLocalizedString(localaizedKey, nil)];
    }
    return label;
}

@end
