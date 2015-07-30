//
//  SystemCommentCell.m
//  IQ300
//
//  Created by Tayphoon on 27.07.15.
//  Copyright (c) 2015 Tayphoon. All rights reserved.
//

#import "SystemCommentCell.h"
#import "IQComment.h"
#import "NSDate+IQFormater.h"

#define CONTENT_INSET 8.0f
#define COMMENT_CELL_MIN_HEIGHT 47.0f
#define TIME_LABEL_HEIGHT 7.0f

#ifdef IPAD
#define DESCRIPTION_LABEL_FONT [UIFont fontWithName:IQ_HELVETICA_BOLD size:14]
#else
#define DESCRIPTION_LABEL_FONT [UIFont fontWithName:IQ_HELVETICA_BOLD size:13]
#endif

@implementation SystemCommentCell

+ (CGFloat)heightForItem:(IQComment *)item expanded:(BOOL)expanded сellWidth:(CGFloat)cellWidth {
    CGFloat contentWidth = cellWidth - CONTENT_INSET * 2.0f;
    CGFloat height = COMMENT_CELL_MIN_HEIGHT;
    
    if([item.body length] > 0) {
        UITextView * descriptionTextView = [[UITextView alloc] init];
        [descriptionTextView setFont:DESCRIPTION_LABEL_FONT];
        descriptionTextView.textContainerInset = UIEdgeInsetsZero;
        descriptionTextView.text = item.body;
        descriptionTextView.textContainer.lineFragmentPadding = 0;
        
        CGSize descriptionSize = [descriptionTextView sizeThatFits:CGSizeMake(contentWidth, CGFLOAT_MAX)];
        height = MAX(ceilf(descriptionSize.height) + TIME_LABEL_HEIGHT + 5.0f + CONTENT_INSET,
                     COMMENT_CELL_MIN_HEIGHT);
    }
    
    return height;
}

+ (BOOL)cellNeedToBeExpandableForItem:(IQComment *)item сellWidth:(CGFloat)cellWidth {
    return NO;
}

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier {
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    
    if(self) {
        _contentInsets = UIEdgeInsetsMake(CONTENT_INSET / 2.0f, CONTENT_INSET, 0.0f, CONTENT_INSET);

        UIView * contentView = self.contentView;
        [self setBackgroundColor:[UIColor clearColor]];
        [self setSelectionStyle:UITableViewCellSelectionStyleNone];
        
        _timeLabel = [[UILabel alloc] init];
        [_timeLabel setFont:[UIFont fontWithName:IQ_HELVETICA size:(IS_IPAD) ? 10.0f : 9.0f]];
        [_timeLabel setTextColor:[UIColor colorWithHexInt:0xb3b3b3]];
        _timeLabel.textAlignment = NSTextAlignmentLeft;
        _timeLabel.backgroundColor = [UIColor clearColor];
        _timeLabel.numberOfLines = 0;
        _timeLabel.textAlignment = NSTextAlignmentCenter;
        [contentView addSubview:_timeLabel];

        _descriptionTextView = [[UITextView alloc] init];
        [_descriptionTextView setFont:DESCRIPTION_LABEL_FONT];
        [_descriptionTextView setTextColor:[UIColor blackColor]];
        _descriptionTextView.textAlignment = NSTextAlignmentLeft;
        _descriptionTextView.textContainer.lineFragmentPadding = 0;
        _descriptionTextView.backgroundColor = [UIColor clearColor];
        _descriptionTextView.editable = NO;
        _descriptionTextView.textContainerInset = UIEdgeInsetsZero;
        _descriptionTextView.scrollEnabled = NO;
        [contentView addSubview:_descriptionTextView];
    }
    
    return self;
}

- (void)setItem:(IQComment *)item {
    _item = item;
    _timeLabel.text = [_item.createDate dateToTimeString];
    
    NSMutableParagraphStyle * paragraphStyle = [[NSParagraphStyle defaultParagraphStyle] mutableCopy];
    paragraphStyle.alignment = NSTextAlignmentCenter;
    
    NSMutableDictionary * attributes = @{
                                         NSParagraphStyleAttributeName  : paragraphStyle,
                                         NSForegroundColorAttributeName : [UIColor blackColor],
                                         NSFontAttributeName            : DESCRIPTION_LABEL_FONT
                                         }.mutableCopy ;

    _descriptionTextView.attributedText = [[NSAttributedString alloc] initWithString:_item.body
                                                                          attributes:attributes];
}

- (BOOL)isExpandable {
    return NO;
}

- (BOOL)isExpanded {
    return NO;
}

- (void)layoutSubviews {
    [super layoutSubviews];
    
    CGRect bounds = self.contentView.bounds;
    CGRect actualBounds = UIEdgeInsetsInsetRect(bounds, _contentInsets);

    _timeLabel.frame = CGRectMake(actualBounds.origin.x,
                                  actualBounds.origin.y,
                                  actualBounds.size.width,
                                  7.0f);
    
    CGFloat descriptionY = CGRectBottom(_timeLabel.frame) + 5.0f;
    _descriptionTextView.frame = CGRectMake(actualBounds.origin.x,
                                            descriptionY,
                                            actualBounds.size.width,
                                            actualBounds.size.height - descriptionY);
}

@end
