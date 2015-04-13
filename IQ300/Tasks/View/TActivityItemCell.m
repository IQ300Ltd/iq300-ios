//
//  TActivityItemCell.m
//  IQ300
//
//  Created by Tayphoon on 01.04.15.
//  Copyright (c) 2015 Tayphoon. All rights reserved.
//

#import "TActivityItemCell.h"
#import "IQTaskActivityItem.h"
#import "NSDate+IQFormater.h"

#define CONTENT_INSETS 13.0f
#define DESCRIPTION_FONT [UIFont fontWithName:IQ_HELVETICA size:15]
#define TITLE_FONT [UIFont fontWithName:IQ_HELVETICA size:13]
#define LABELS_HEIGHT 17.0f
#define LABELS_OFFSET 5.0f
#define ACTION_MAX_HEIGHT 35
#define DESCR_MAX_HEIGHT 55

@implementation TActivityItemCell

+ (CGFloat)heightForItem:(IQTaskActivityItem*)item andCellWidth:(CGFloat)cellWidth {
    CGFloat width = cellWidth - CONTENT_INSETS * 2.0f;
    CGFloat height = CONTENT_INSETS * 2 + LABELS_HEIGHT;
    
    if([item.event length] > 0) {
        CGSize titleSize = [item.event sizeWithFont:TITLE_FONT
                                  constrainedToSize:CGSizeMake(width, ACTION_MAX_HEIGHT)
                                      lineBreakMode:NSLineBreakByWordWrapping];
        height += ceilf(titleSize.height) + LABELS_OFFSET;
    }
    
    if([item.changes length] > 0) {
        CGSize desSize = [item.changes sizeWithFont:DESCRIPTION_FONT
                                  constrainedToSize:CGSizeMake(width, DESCR_MAX_HEIGHT)
                                      lineBreakMode:NSLineBreakByWordWrapping];
        height += ceilf(desSize.height) + LABELS_OFFSET;
    }
    
    return MIN(height, ACTIVITY_CELL_MAX_HEIGHT);
}

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier {
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    
    if(self) {
        _contentInsets = UIEdgeInsetsMakeWithInset(CONTENT_INSETS);

        UIView * contentView = self.contentView;
        self.selectionStyle = UITableViewCellSelectionStyleNone;
        self.backgroundColor = [UIColor whiteColor];
        
        _dateLabel = [self makeLabelWithTextColor:[UIColor colorWithHexInt:0x9f9f9f]
                                             font:[UIFont fontWithName:IQ_HELVETICA size:13]
                                    localaizedKey:nil];
        _dateLabel.textAlignment = NSTextAlignmentLeft;
        _dateLabel.lineBreakMode = NSLineBreakByTruncatingTail;
        [contentView addSubview:_dateLabel];
        
        _userNameLabel = [self makeLabelWithTextColor:[UIColor colorWithHexInt:0x9f9f9f]
                                                 font:[UIFont fontWithName:IQ_HELVETICA size:13]
                                        localaizedKey:nil];
        _userNameLabel.textAlignment = NSTextAlignmentRight;
        _dateLabel.lineBreakMode = NSLineBreakByTruncatingTail;
        [contentView addSubview:_userNameLabel];
        
        _actionLabel = [self makeLabelWithTextColor:[UIColor colorWithHexInt:0x9f9f9f]
                                               font:TITLE_FONT
                                      localaizedKey:nil];
        _actionLabel.lineBreakMode = NSLineBreakByTruncatingTail;
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
    CGFloat labelsMaxWidth = actualBounds.size.width / 2.0f;
    CGSize constrainedSize = CGSizeMake(labelsMaxWidth,
                                        LABELS_HEIGHT);

    CGSize dateSize = [_dateLabel.text sizeWithFont:_dateLabel.font
                                  constrainedToSize:constrainedSize
                                      lineBreakMode:_dateLabel.lineBreakMode];

    _dateLabel.frame = CGRectMake(actualBounds.origin.x,
                                  actualBounds.origin.y,
                                  dateSize.width,
                                  LABELS_HEIGHT);
    
    CGFloat userLabelX = CGRectRight(_dateLabel.frame) + LABELS_OFFSET;
    _userNameLabel.frame = CGRectMake(userLabelX,
                                      actualBounds.origin.y,
                                      actualBounds.size.width - dateSize.width,
                                      LABELS_HEIGHT);
    
    CGSize actionSize = [_actionLabel.text sizeWithFont:_dateLabel.font
                                  constrainedToSize:CGSizeMake(actualBounds.size.width, ACTION_MAX_HEIGHT)
                                      lineBreakMode:NSLineBreakByWordWrapping];

    _actionLabel.frame = CGRectMake(actualBounds.origin.x,
                                    CGRectBottom(_dateLabel.frame) + LABELS_OFFSET,
                                    actualBounds.size.width,
                                    ceilf(actionSize.height));
    
    CGFloat descriptionY = (actionSize.height > 0) ? CGRectBottom(_actionLabel.frame) + LABELS_OFFSET :
                                                     CGRectBottom(_userNameLabel.frame) + LABELS_OFFSET;
    _descriptionLabel.frame = CGRectMake(actualBounds.origin.x,
                                         descriptionY,
                                         actualBounds.size.width,
                                         actualBounds.origin.y + actualBounds.size.height - descriptionY);
}

- (void)setItem:(IQTaskActivityItem *)item {
    _item = item;
    
    _userNameLabel.text = _item.authorName;
    _dateLabel.text = [_item.createdDate dateToTimeDayString];
    _actionLabel.text = _item.event;
    _descriptionLabel.text = _item.changes;
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
