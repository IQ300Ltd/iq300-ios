//
//  ConversationCell.m
//  IQ300
//
//  Created by Tayphoon on 02.12.14.
//  Copyright (c) 2014 Tayphoon. All rights reserved.
//
#import <QuartzCore/QuartzCore.h>

#import "ConversationCell.h"
#import "NSDate+IQFormater.h"
#import "IQBadgeView.h"
#import "IQConversation.h"
#import "IQSession.h"

#define HEIGHT_DELTA 1.0f
#define VERTICAL_PADDING 10
#define DESCRIPTION_Y_OFFSET 3.0f
#define CELL_HEADER_MIN_HEIGHT 15
#define CONTEN_BACKGROUND_COLOR [UIColor colorWithHexInt:0xe9faff]
#define CONTEN_BACKGROUND_COLOR_R [UIColor whiteColor]
#define DESCRIPTION_LABEL_FONT [UIFont fontWithName:IQ_HELVETICA size:13]

@implementation ConversationCell

+ (CGFloat)heightForItem:(IQConversation *)item andCellWidth:(CGFloat)cellWidth {
    CGFloat descriptionY = CELL_HEADER_MIN_HEIGHT;
    CGFloat descriptionWidth = cellWidth;

    if([item.lastComment.body length] > 0) {
        CGSize descriptionSize = [item.lastComment.body sizeWithFont:DESCRIPTION_LABEL_FONT
                                                   constrainedToSize:CGSizeMake(descriptionWidth, CONVERSATION_CELL_MAX_HEIGHT)
                                                       lineBreakMode:NSLineBreakByWordWrapping];
        return MAX(descriptionY + descriptionSize.height + VERTICAL_PADDING * 2.0f + DESCRIPTION_Y_OFFSET + HEIGHT_DELTA,
                   CONVERSATION_CELL_MIN_HEIGHT);
    }
    return CONVERSATION_CELL_MIN_HEIGHT;
}

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier {
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    
    if(self) {
        UIView * contentView = self.contentView;
        
        _contentInsets = UIEdgeInsetsMake(VERTICAL_PADDING, 8, 0.0f, 8);
        _contentBackgroundInsets = UIEdgeInsetsZero;
        
        [self setSelectionStyle:UITableViewCellSelectionStyleNone];
        
        [self setBackgroundColor:[UIColor colorWithHexInt:0x005275]];
        
        _contentBackgroundView = [[UIView alloc] init];
        _contentBackgroundView.backgroundColor = CONTEN_BACKGROUND_COLOR_R;
        [contentView addSubview:_contentBackgroundView];
        
        _dateLabel = [self makeLabelWithTextColor:[UIColor colorWithHexInt:0xb3b3b3]
                                             font:[UIFont fontWithName:IQ_HELVETICA size:13]
                                    localaizedKey:nil];
        _dateLabel.textAlignment = NSTextAlignmentRight;
        [contentView addSubview:_dateLabel];
        
        _userNameLabel = [self makeLabelWithTextColor:[UIColor colorWithHexInt:0x358bae]
                                                 font:[UIFont fontWithName:IQ_HELVETICA size:13]
                                        localaizedKey:nil];
        _userNameLabel.backgroundColor = [UIColor clearColor];
        _userNameLabel.textAlignment = NSTextAlignmentLeft;
        [contentView addSubview:_userNameLabel];
                
        _descriptionLabel = [self makeLabelWithTextColor:[UIColor colorWithHexInt:0x8b8b8b]
                                                    font:DESCRIPTION_LABEL_FONT
                                           localaizedKey:nil];
        [contentView addSubview:_descriptionLabel];
        
        BadgeStyle * style = [BadgeStyle defaultStyle];
        style.badgeTextColor = [UIColor whiteColor];
        style.badgeInsetColor = [UIColor colorWithHexInt:0x338cae];
     
        _badgeView = [IQBadgeView customBadgeWithString:nil withStyle:style];
        _badgeView.badgeMinSize = 15;
        _badgeView.badgeTextFont = [UIFont fontWithName:IQ_HELVETICA size:10];
        [_badgeView setHidden:YES];
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
    
    CGSize topLabelSize = CGSizeMake(actualBounds.size.width / 2.0f, CELL_HEADER_MIN_HEIGHT);
    _userNameLabel.frame = CGRectMake(actualBounds.origin.x + labelsOffset,
                                  actualBounds.origin.y,
                                  topLabelSize.width,
                                  topLabelSize.height);
    
    _dateLabel.frame = CGRectMake(actualBounds.origin.x + actualBounds.size.width - topLabelSize.width,
                                  actualBounds.origin.y,
                                  topLabelSize.width,
                                  topLabelSize.height);
    
    CGFloat descriptionY = CGRectBottom(_userNameLabel.frame) + DESCRIPTION_Y_OFFSET;
    _descriptionLabel.frame = CGRectMake(actualBounds.origin.x + labelsOffset,
                                         descriptionY,
                                         actualBounds.size.width,
                                         actualBounds.size.height - descriptionY);
    
    _badgeView.frame = CGRectMake(actualBounds.origin.x + actualBounds.size.width - _badgeView.frame.size.width,
                                  actualBounds.origin.y + (actualBounds.size.height - _badgeView.frame.size.height) / 2,
                                  _badgeView.frame.size.width,
                                  _badgeView.frame.size.height);
}

- (void)setItem:(IQConversation *)item {
    _item = item;
    
    BOOL hasUnreadComments = ([_item.unreadCommentsCount integerValue] > 0);
    BOOL lastCommentIsMine = ([_item.lastComment.author.userId isEqualToNumber:[IQSession defaultSession].userId]);
    _contentBackgroundInsets = (hasUnreadComments) ? UIEdgeInsetsMake(0, 4, 0, 0) : UIEdgeInsetsZero;
    _contentBackgroundView.backgroundColor = (hasUnreadComments) ? CONTEN_BACKGROUND_COLOR :
                                                                   CONTEN_BACKGROUND_COLOR_R;
    NSPredicate * companionsPredicate = [NSPredicate predicateWithFormat:@"userId != %@", [IQSession defaultSession].userId];
    NSArray * companions = [[_item.discussion.users filteredSetUsingPredicate:companionsPredicate] allObjects];
    IQUser * companion = [companions lastObject];
    
    _dateLabel.text = [_item.lastComment.createDate dateToDayTimeString];
    _userNameLabel.hidden = ([companion.displayName length] == 0);
    _userNameLabel.text = companion.displayName;
    _companionName = companion.displayName;
    
    NSString * descriptionAuthor = (lastCommentIsMine) ? [NSString stringWithFormat:@"%@:", NSLocalizedString(@"I", nil)] : @"";
    _descriptionLabel.text = [NSString stringWithFormat:@"%@ %@", descriptionAuthor, _item.lastComment.body];
    [self setBadgeText:(hasUnreadComments) ? [_item.unreadCommentsCount stringValue] : nil];
    [self setNeedsLayout];
}

- (void)prepareForReuse {
    [super prepareForReuse];
    
    _contentBackgroundInsets = UIEdgeInsetsZero;
    _contentBackgroundView.backgroundColor = CONTEN_BACKGROUND_COLOR_R;
    _companionName = nil;
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

- (void)setBadgeText:(NSString *)badgeText {
    if([badgeText length] > 0) {
        [_badgeView setHidden:NO];
        [_badgeView autoBadgeSizeWithString:badgeText];
    }
    else {
        [_badgeView setHidden:YES];
    }
}

@end
