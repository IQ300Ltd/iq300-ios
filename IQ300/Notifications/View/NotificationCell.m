//
//  Notifications].m
//  IQ300
//
//  Created by Tayphoon on 21.11.14.
//  Copyright (c) 2014 Tayphoon. All rights reserved.
//
#import <QuartzCore/QuartzCore.h>

#import "NotificationCell.h"
#import "IQNotification.h"
#import "NSDate+IQFormater.h"


@interface NotificationCell() {
}

@end

@implementation NotificationCell

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier {
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    
    if(self) {
        UIView * contentView = [super valueForKey:@"_contentCellView"];
        self.selectionStyle = UITableViewCellSelectionStyleNone;
        
        _markAsReadedButton = [[UIButton alloc] init];
        [_markAsReadedButton setBackgroundColor:[UIColor colorWithHexInt:0x005275]];
        [_markAsReadedButton setImage:[UIImage imageNamed:@"check_mark_medium"] forState:UIControlStateNormal];
        
        _contentInsets = UIEdgeInsetsMake(5, 8, 5, 8);
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
        [contentView addSubview:_actionLabel];
        
        _descriptionLabel = [self makeLabelWithTextColor:[UIColor colorWithHexInt:0x9b9c9e]
                                                    font:[UIFont fontWithName:IQ_HELVETICA size:13]
                                           localaizedKey:nil];
        [contentView addSubview:_descriptionLabel];
    }
    
    return self;
}

- (void)layoutSubviews {
    [super layoutSubviews];
    
    CGRect bounds = self.contentView.bounds;
    CGRect actualBounds = UIEdgeInsetsInsetRect(bounds, _contentInsets);
    CGFloat labelsOffset = 5.0f;
    
    CGRect contentBackgroundBounds = UIEdgeInsetsInsetRect(bounds, _contentBackgroundInsets);
    _contentBackgroundView.frame = contentBackgroundBounds;
    
    CGSize topLabelSize = CGSizeMake(actualBounds.size.width / 2.0f, 12);
    _typeLabel.frame = CGRectMake(actualBounds.origin.x + labelsOffset,
                                  actualBounds.origin.y,
                                  topLabelSize.width,
                                  topLabelSize.height);
    
    _dateLabel.frame = CGRectMake(actualBounds.origin.x + actualBounds.size.width - topLabelSize.width,
                                  actualBounds.origin.y,
                                  topLabelSize.width,
                                  topLabelSize.height);
    
    _titleLabel.frame = CGRectMake(actualBounds.origin.x + labelsOffset,
                                   _typeLabel.frame.origin.y + _typeLabel.frame.size.height + 4,
                                   actualBounds.size.width,
                                   16);
    
    CGFloat userNameHeight = 17;
    CGFloat userNameMaxWidth = actualBounds.size.width / 2.0f;
    CGSize constrainedSize = CGSizeMake(userNameMaxWidth,
                                        userNameHeight);
    
    CGPoint actionLabelLocation = CGPointMake(actualBounds.origin.x, CGRectBottom(_titleLabel.frame) + 5);
    if (([_item.user.displayName length] > 0)) {
        CGSize userSize = [_userNameLabel.text sizeWithFont:_userNameLabel.font
                                          constrainedToSize:constrainedSize
                                              lineBreakMode:_userNameLabel.lineBreakMode];
        
        _userNameLabel.frame = CGRectMake(actualBounds.origin.x,
                                          CGRectBottom(_titleLabel.frame) + 5,
                                          userSize.width + 5,
                                          userNameHeight);
        actionLabelLocation = CGPointMake(CGRectRight(_userNameLabel.frame) + 7, _userNameLabel.frame.origin.y);
    }
    else {
        _userNameLabel.frame = CGRectZero;
        actionLabelLocation = CGPointMake(actualBounds.origin.x, CGRectBottom(_titleLabel.frame) + 5);
    }

    
    _actionLabel.frame = CGRectMake(actionLabelLocation.x + labelsOffset,
                                    actionLabelLocation.y,
                                    actualBounds.size.width - actionLabelLocation.x,
                                    userNameHeight);
    
    CGFloat descriptionY = CGRectBottom(_actionLabel.frame);
    _descriptionLabel.frame = CGRectMake(actualBounds.origin.x + labelsOffset,
                                         descriptionY,
                                         actualBounds.size.width,
                                         actualBounds.size.height - descriptionY);
}

- (void)setItem:(IQNotification *)item {
    _item = item;
    
    BOOL isReaded = [_item.readed boolValue] || [_item.hasActions boolValue];
    _contentBackgroundInsets = (isReaded) ? UIEdgeInsetsZero : UIEdgeInsetsMake(0, READ_FLAG_WIDTH, 0, 0);
    _contentBackgroundView.backgroundColor = (isReaded) ? CONTEN_BACKGROUND_COLOR_R :
                                                          CONTEN_BACKGROUND_COLOR;
    self.rightUtilityButtons = (isReaded) ? nil : @[_markAsReadedButton];
    
    _typeLabel.text = NSLocalizedString(_item.notificable.type, nil);
    _dateLabel.text = [_item.createdAt dateToDayTimeString];
    _titleLabel.text = _item.notificable.title;
    _userNameLabel.hidden = ([_item.user.displayName length] == 0);
    _userNameLabel.text = _item.user.displayName;
    _actionLabel.text = _item.mainDescription;
    _descriptionLabel.text = _item.additionalDescription;
    [self setNeedsLayout];
}

- (void)prepareForReuse {
    [super prepareForReuse];
    
    _contentBackgroundInsets = UIEdgeInsetsZero;
    _contentBackgroundView.backgroundColor = CONTEN_BACKGROUND_COLOR_R;
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
