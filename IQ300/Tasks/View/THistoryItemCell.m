//
//  THistoryItemCell.m
//  IQ300
//
//  Created by Tayphoon on 01.04.15.
//  Copyright (c) 2015 Tayphoon. All rights reserved.
//

#import "THistoryItemCell.h"

#define HORIZONTAL_INSETS 8.0f
#define VERTICAL_INSETS 5.0f
#define DESCRIPTION_FONT [UIFont fontWithName:IQ_HELVETICA size:13]
#define DESCRIPTION_MIN_HEIGHT 19.0f

@implementation THistoryItemCell

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier {
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    
    if(self) {
        _contentInsets = UIEdgeInsetsMake(VERTICAL_INSETS, HORIZONTAL_INSETS, VERTICAL_INSETS, HORIZONTAL_INSETS);

        UIView * contentView = self.contentView;
        self.selectionStyle = UITableViewCellSelectionStyleNone;
        self.backgroundColor = [UIColor whiteColor];
        
        _dateLabel = [self makeLabelWithTextColor:[UIColor colorWithHexInt:0x9f9f9f]
                                             font:[UIFont fontWithName:IQ_HELVETICA size:13]
                                    localaizedKey:nil];
        _dateLabel.textAlignment = NSTextAlignmentLeft;
        [contentView addSubview:_dateLabel];
        
        _userNameLabel = [self makeLabelWithTextColor:[UIColor colorWithHexInt:0x9f9f9f]
                                                 font:[UIFont fontWithName:IQ_HELVETICA size:13]
                                        localaizedKey:nil];
        _userNameLabel.textAlignment = NSTextAlignmentRight;
        [contentView addSubview:_userNameLabel];
        
        _actionLabel = [self makeLabelWithTextColor:[UIColor colorWithHexInt:0x9f9f9f]
                                               font:[UIFont fontWithName:IQ_HELVETICA size:13]
                                      localaizedKey:nil];
        [contentView addSubview:_actionLabel];
        
        _descriptionLabel = [self makeLabelWithTextColor:[UIColor colorWithHexInt:0x20272a]
                                                    font:DESCRIPTION_FONT
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
    
    _dateLabel.frame = CGRectMake(actualBounds.origin.x + labelsOffset,
                                  actualBounds.origin.y,
                                  actualBounds.size.width - labelsOffset * 2.0f,
                                  14);
    
    CGFloat userNameHeight = 17;
    CGFloat userNameMaxWidth = actualBounds.size.width / 2.0f;
    CGSize constrainedSize = CGSizeMake(userNameMaxWidth,
                                        userNameHeight);
    
    CGPoint actionLabelLocation = CGPointZero;
//    if (([_item.user.displayName length] > 0)) {
//        CGSize userSize = [_userNameLabel.text sizeWithFont:_userNameLabel.font
//                                          constrainedToSize:constrainedSize
//                                              lineBreakMode:_userNameLabel.lineBreakMode];
//        
//        _userNameLabel.frame = CGRectMake(actualBounds.origin.x,
//                                          CGRectBottom(_dateLabel.frame) + 5,
//                                          userSize.width + 5,
//                                          userNameHeight);
//        actionLabelLocation = CGPointMake(CGRectRight(_userNameLabel.frame) + 7, _userNameLabel.frame.origin.y);
//    }
//    else {
//        _userNameLabel.frame = CGRectZero;
//        actionLabelLocation = CGPointMake(actualBounds.origin.x, CGRectBottom(_dateLabel.frame) + 5);
//    }
    
    
    _actionLabel.frame = CGRectMake(actionLabelLocation.x + labelsOffset,
                                    actionLabelLocation.y,
                                    actualBounds.size.width - actionLabelLocation.x,
                                    userNameHeight);
    
    CGFloat descriptionY = CGRectBottom(_actionLabel.frame) + labelsOffset;
    _descriptionLabel.frame = CGRectMake(actualBounds.origin.x + labelsOffset,
                                         descriptionY,
                                         actualBounds.size.width,
                                         actualBounds.size.height - descriptionY);
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
