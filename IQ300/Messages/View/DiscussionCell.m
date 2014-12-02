//
//  ConversationCell.m
//  IQ300
//
//  Created by Tayphoon on 02.12.14.
//  Copyright (c) 2014 Tayphoon. All rights reserved.
//
#import <QuartzCore/QuartzCore.h>

#import "DiscussionCell.h"
#import "NSDate+CupertinoYankee.h"
#import "IQBadgeView.h"

#define CONTEN_BACKGROUND_COLOR [UIColor colorWithHexInt:0xe9faff]
#define CONTEN_BACKGROUND_COLOR_R [UIColor whiteColor]

@implementation DiscussionCell

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier {
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    
    if(self) {
        UIView * contentView = self.contentView;
        
        _contentInsets = UIEdgeInsetsMake(5, 8, 5, 8);
        _contentBackgroundInsets = UIEdgeInsetsZero;
        
        [self setBackgroundColor:[UIColor colorWithHexInt:0x005275]];
        
        _contentBackgroundView = [[UIView alloc] init];
        _contentBackgroundView.backgroundColor = CONTEN_BACKGROUND_COLOR;
        [contentView addSubview:_contentBackgroundView];
        
        _dateLabel = [self makeLabelWithTextColor:[UIColor colorWithHexInt:0xb3b3b3]
                                             font:[UIFont fontWithName:IQ_HELVETICA size:13]
                                    localaizedKey:nil];
        _dateLabel.textAlignment = NSTextAlignmentRight;
        [contentView addSubview:_dateLabel];
        
        _userNameLabel = [self makeLabelWithTextColor:[UIColor whiteColor]
                                                 font:[UIFont fontWithName:IQ_HELVETICA size:13]
                                        localaizedKey:nil];
        _userNameLabel.backgroundColor = [UIColor colorWithHexInt:0xcccccc];
        _userNameLabel.layer.cornerRadius = 3;
        _userNameLabel.textAlignment = NSTextAlignmentCenter;
        _userNameLabel.clipsToBounds = YES;
        [contentView addSubview:_userNameLabel];
                
        _descriptionLabel = [self makeLabelWithTextColor:[UIColor colorWithHexInt:0x9b9c9e]
                                                    font:[UIFont fontWithName:IQ_HELVETICA size:13]
                                           localaizedKey:nil];
        [contentView addSubview:_descriptionLabel];
        
        _badgeView = [IQBadgeView customBadgeWithString:nil];
        [contentView addSubview:_badgeView];
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
    _userNameLabel.frame = CGRectMake(actualBounds.origin.x + labelsOffset,
                                  actualBounds.origin.y,
                                  topLabelSize.width,
                                  topLabelSize.height);
    
    _dateLabel.frame = CGRectMake(actualBounds.origin.x + actualBounds.size.width - topLabelSize.width,
                                  actualBounds.origin.y,
                                  topLabelSize.width,
                                  topLabelSize.height);
    
    CGFloat descriptionY = CGRectBottom(_userNameLabel.frame);
    _descriptionLabel.frame = CGRectMake(actualBounds.origin.x + labelsOffset,
                                         descriptionY,
                                         actualBounds.size.width,
                                         actualBounds.size.height - descriptionY);
}

- (void)setItem:(IQDiscussion *)item {
    _item = item;
    
//    _contentBackgroundInsets = ([_item.readed boolValue]) ? UIEdgeInsetsZero : UIEdgeInsetsMake(0, 4, 0, 0);
//    _contentBackgroundView.backgroundColor = ([_item.readed boolValue]) ? CONTEN_BACKGROUND_COLOR_R :
//    CONTEN_BACKGROUND_COLOR;
//    self.rightUtilityButtons = ([_item.readed boolValue]) ? nil : @[_markAsReadedButton];
//    
//    _typeLabel.text = NSLocalizedString(_item.notificable.type, nil);
//    _dateLabel.text = [self dateToString:_item.createdAt];
//    _titleLabel.text = _item.notificable.title;
//    _userNameLabel.hidden = ([_item.user.displayName length] == 0);
//    _userNameLabel.text = _item.user.displayName;
//    _actionLabel.text = _item.mainDescription;
//    _descriptionLabel.text = _item.additionalDescription;
//    [self setNeedsLayout];
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

- (NSString*)dateToString:(NSDate*)date {
    NSString * stringDate = nil;
    NSDate * today = [[NSDate date] beginningOfDay];
    NSDate * yesterday = [today prevDay];
    NSDate * beginningOfDay = [date beginningOfDay];
    
    if([beginningOfDay compare:today] == NSOrderedSame) {
        NSDateFormatter * timeFormatter = [self dateFormater];
        [timeFormatter setDateFormat:@"hh:mm"];
        stringDate = [NSString stringWithFormat:@"%@, %@", NSLocalizedString(@"Today", nil), [timeFormatter stringFromDate:date]];
    }
    else if([beginningOfDay compare:yesterday] == NSOrderedSame) {
        stringDate = NSLocalizedString(@"Yesterday", nil);
    }
    else {
        NSDateFormatter *dateFormatter = [self dateFormater];
        [dateFormatter setDateFormat:@"yyyy-MM-dd"];
        stringDate = [dateFormatter stringFromDate:date];
    }
    
    return stringDate;
}

- (NSDateFormatter *)dateFormater {
    static NSDateFormatter *dateFormatter = nil;
    
    if (!dateFormatter) {
        dateFormatter = [[NSDateFormatter alloc] init];
        [dateFormatter setTimeZone:[NSTimeZone systemTimeZone]];
    }
    
    return dateFormatter;
}

@end
