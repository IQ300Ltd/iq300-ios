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

#ifdef IPAD
#define DEFAULT_FONT_SIZE 14
#define DESCRIPTION_MIN_HEIGHT 19.0f
#define TITLE_MAX_HEIGHT 20
#define TITLE_FONT [UIFont fontWithName:IQ_HELVETICA size:17]
#else
#define DEFAULT_FONT_SIZE 13
#define DESCRIPTION_MIN_HEIGHT 17.0f
#define TITLE_MAX_HEIGHT 17
#define TITLE_FONT [UIFont fontWithName:IQ_HELVETICA size:14]
#endif

#define HORIZONTAL_INSETS 8.0f
#define VERTICAL_INSETS 5.0f
#define DESCRIPTION_FONT [UIFont fontWithName:IQ_HELVETICA size:DEFAULT_FONT_SIZE]

@implementation NotificationCell

+ (CGFloat)heightForItem:(IQNotification *)notification andCellWidth:(CGFloat)cellWidth {
    CGFloat width = cellWidth - HORIZONTAL_INSETS * 2.0f - 40;
    CGFloat height = NOTIFICATION_CELL_MIN_HEIGHT - DESCRIPTION_MIN_HEIGHT;
    
    if([notification.notificable.title length] > 0) {
        height = MAX(height + TITLE_MAX_HEIGHT, height);
    }
    
    if([notification.additionalDescription length] > 0) {
        CGSize constrainedSize = CGSizeMake(width,
                                            NOTIFICATION_CELL_MAX_HEIGHT);
        
        CGSize desSize = [notification.additionalDescription sizeWithFont:DESCRIPTION_FONT
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
        [self setBackgroundColor:READ_FLAG_COLOR];
        
        _pinnedButton = [[UIButton alloc] init];
        [_pinnedButton setBackgroundColor:[UIColor colorWithHexInt:0x005275]];
        [_pinnedButton setImage:[UIImage imageNamed:@"pinned.png"] forState:UIControlStateNormal];
   
        _markAsReadedButton = [[UIButton alloc] init];
        [_markAsReadedButton setBackgroundColor:[UIColor colorWithHexInt:0x005275]];
        [_markAsReadedButton setImage:[UIImage imageNamed:@"check_mark_medium"] forState:UIControlStateNormal];
        
        _contentInsets = UIEdgeInsetsMake(VERTICAL_INSETS, HORIZONTAL_INSETS, VERTICAL_INSETS, HORIZONTAL_INSETS);
        _contentBackgroundInsets = UIEdgeInsetsZero;
        
        _contentBackgroundView = [[UIView alloc] init];
        _contentBackgroundView.backgroundColor = CONTEN_BACKGROUND_COLOR;
        [contentView addSubview:_contentBackgroundView];
        
        _typeLabel = [self makeLabelWithTextColor:[UIColor colorWithHexInt:0xb3b3b3]
                                             font:[UIFont fontWithName:IQ_HELVETICA size:DEFAULT_FONT_SIZE]
                                    localaizedKey:@"Project"];
        [contentView addSubview:_typeLabel];
        
        _dateLabel = [self makeLabelWithTextColor:[UIColor colorWithHexInt:0xb3b3b3]
                                             font:[UIFont fontWithName:IQ_HELVETICA size:DEFAULT_FONT_SIZE]
                                    localaizedKey:nil];
        _dateLabel.textAlignment = NSTextAlignmentRight;
        [contentView addSubview:_dateLabel];
        
        _titleLabel = [self makeLabelWithTextColor:[UIColor colorWithHexInt:0x272727]
                                              font:TITLE_FONT
                                     localaizedKey:nil];
        _titleLabel.lineBreakMode = NSLineBreakByTruncatingTail;
        [contentView addSubview:_titleLabel];
        
        _userNameLabel = [self makeLabelWithTextColor:[UIColor whiteColor]
                                                 font:[UIFont fontWithName:IQ_HELVETICA size:DEFAULT_FONT_SIZE]
                                        localaizedKey:nil];
        _userNameLabel.backgroundColor = [UIColor colorWithHexInt:0xcccccc];
        _userNameLabel.layer.cornerRadius = 3;
        _userNameLabel.textAlignment = NSTextAlignmentCenter;
        _userNameLabel.clipsToBounds = YES;
        [contentView addSubview:_userNameLabel];
        
        _actionLabel = [self makeLabelWithTextColor:[UIColor colorWithHexInt:0x272727]
                                               font:[UIFont fontWithName:IQ_HELVETICA size:DEFAULT_FONT_SIZE]
                                      localaizedKey:nil];
        _actionLabel.lineBreakMode = NSLineBreakByTruncatingTail;
        [contentView addSubview:_actionLabel];
        
        _descriptionLabel = [self makeLabelWithTextColor:[UIColor colorWithHexInt:0x9b9c9e]
                                                    font:[UIFont fontWithName:IQ_HELVETICA size:DEFAULT_FONT_SIZE]
                                           localaizedKey:nil];
        _descriptionLabel.lineBreakMode = NSLineBreakByTruncatingTail;
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
    
    CGSize topLabelSize = CGSizeMake((actualBounds.size.width - labelsOffset) / 2.0f,
                                     (IS_IPAD) ? 17.0f : 14.0f);
    _typeLabel.frame = CGRectMake(actualBounds.origin.x + labelsOffset,
                                  actualBounds.origin.y,
                                  topLabelSize.width,
                                  topLabelSize.height);
    
    _dateLabel.frame = CGRectMake(actualBounds.origin.x + actualBounds.size.width - topLabelSize.width,
                                  actualBounds.origin.y,
                                  topLabelSize.width,
                                  topLabelSize.height);
    
    if([_item.notificable.title length] > 0) {
        _titleLabel.frame = CGRectMake(actualBounds.origin.x + labelsOffset,
                                       _typeLabel.frame.origin.y + _typeLabel.frame.size.height + 4,
                                       actualBounds.size.width - 5.0f,
                                       TITLE_MAX_HEIGHT);
    }
    else {
        _titleLabel.frame = CGRectMake(actualBounds.origin.x + labelsOffset,
                                       _typeLabel.frame.origin.y + _typeLabel.frame.size.height + 4,
                                       0.0f,
                                       0.0f);
    }
    
    CGFloat userNameHeight = 17;
    CGFloat userNameMaxWidth = actualBounds.size.width / 2.0f;
    CGSize constrainedSize = CGSizeMake(userNameMaxWidth,
                                        userNameHeight);
    
    CGPoint actionLabelLocation = CGPointZero;
    if (([_item.user.displayName length] > 0)) {
        CGSize userSize = [_userNameLabel.text sizeWithFont:_userNameLabel.font
                                          constrainedToSize:constrainedSize
                                              lineBreakMode:NSLineBreakByWordWrapping];
        
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
    
    CGFloat descriptionY = CGRectBottom(_actionLabel.frame) + 5.0f;
    _descriptionLabel.frame = CGRectMake(actualBounds.origin.x + labelsOffset,
                                         descriptionY,
                                         actualBounds.size.width - 40.0f,
                                         actualBounds.size.height - descriptionY);
}

- (void)setItem:(IQNotification *)item {
    _item = item;
    
    BOOL isReaded = [_item.readed boolValue] || [_item.hasActions boolValue];
    _contentBackgroundInsets = (isReaded) ? UIEdgeInsetsZero : UIEdgeInsetsMake(0, READ_FLAG_WIDTH, 0, 0);
    _contentBackgroundView.backgroundColor = (isReaded) ? CONTEN_BACKGROUND_COLOR_R :
    CONTEN_BACKGROUND_COLOR;
    self.rightUtilityButtons = (isReaded || [_item.isPinned boolValue]) ? nil : @[_markAsReadedButton];
    
    _typeLabel.text = _item.notificable.translatedType;
    _dateLabel.text = [_item.createdAt dateToDayTimeString];
    _titleLabel.text = _item.notificable.title;
    _userNameLabel.hidden = ([_item.user.displayName length] == 0);
    _userNameLabel.text = _item.user.displayName;
    _actionLabel.text = _item.mainDescription;
    _descriptionLabel.text = _item.additionalDescription;
    
    NSString * pinnedImageName = ([_item.isPinned boolValue]) ? @"unpinned.png" : @"pinned.png";
    [_pinnedButton setImage:[UIImage imageNamed:pinnedImageName] forState:UIControlStateNormal];
    if (![_item.hasActions boolValue]) {
        self.leftUtilityButtons = @[_pinnedButton];
    }

    [self setNeedsLayout];
}

- (void)prepareForReuse {
    [super prepareForReuse];
    
    _contentBackgroundInsets = UIEdgeInsetsZero;
    _contentBackgroundView.backgroundColor = CONTEN_BACKGROUND_COLOR_R;
    
    self.leftUtilityButtons = nil;
    self.rightUtilityButtons = nil;
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
