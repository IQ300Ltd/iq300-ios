//
//  CommentCell.m
//  IQ300
//
//  Created by Tayphoon on 04.12.14.
//  Copyright (c) 2014 Tayphoon. All rights reserved.
//
#import <QuartzCore/QuartzCore.h>

#import "CommentCell.h"
#import "NSDate+IQFormater.h"
#import "IQBadgeView.h"
#import "IQConversation.h"
#import "IQSession.h"

#define ATTACHMENT_VIEW_HEIGHT 15.0f
#define HEIGHT_DELTA 1.0f
#define VERTICAL_PADDING 10
#define DESCRIPTION_Y_OFFSET 3.0f
#define CELL_HEADER_MIN_HEIGHT 15
#define CONTEN_BACKGROUND_COLOR [UIColor colorWithHexInt:0xe9faff]
#define CONTEN_BACKGROUND_COLOR_R [UIColor whiteColor]
#define DESCRIPTION_LABEL_FONT [UIFont fontWithName:IQ_HELVETICA size:13]

@implementation CommentCell

+ (CGFloat)heightForItem:(IQComment *)item andCellWidth:(CGFloat)cellWidth {
    CGFloat descriptionY = CELL_HEADER_MIN_HEIGHT;
    CGFloat descriptionWidth = cellWidth;
    CGFloat height = COMMENT_CELL_MIN_HEIGHT; 
    
    if([item.body length] > 0) {
        CGSize descriptionSize = [item.body sizeWithFont:DESCRIPTION_LABEL_FONT
                                                   constrainedToSize:CGSizeMake(descriptionWidth, COMMENT_CELL_MAX_HEIGHT)
                                                       lineBreakMode:NSLineBreakByWordWrapping];
        height = MAX(descriptionY + descriptionSize.height + VERTICAL_PADDING * 2.0f + DESCRIPTION_Y_OFFSET + HEIGHT_DELTA,
                   COMMENT_CELL_MIN_HEIGHT);
    }
    
    BOOL hasDescription = ([item.body length] > 0);
    BOOL hasAttachment = ([item.attachments count] > 0);
    if(hasAttachment && hasDescription) {
        height += ATTACHMENT_VIEW_HEIGHT;
    }
    
    return height;
}

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier {
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    
    if(self) {
        UIView * contentView = self.contentView;
        [self setBackgroundColor:[UIColor clearColor]];
        [self setSelectionStyle:UITableViewCellSelectionStyleNone];
       
        _contentInsets = UIEdgeInsetsMake(VERTICAL_PADDING, 8, 0.0f, 8);
        
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

        _attachButton = [[UIButton alloc] init];
        [_attachButton setImage:[UIImage imageNamed:@"attach_ico.png"] forState:UIControlStateNormal];
        [_attachButton.titleLabel setFont:[UIFont fontWithName:IQ_HELVETICA size:11]];
        [_attachButton setTitleColor:[UIColor colorWithHexInt:0x358bae] forState:UIControlStateNormal];
        [_attachButton setTitleColor:[UIColor colorWithHexInt:0x446b7a] forState:UIControlStateHighlighted];
        [_attachButton setTitleEdgeInsets:UIEdgeInsetsMake(0.0f, 5.0f, 0.0f, 0.0f)];
        _attachButton.contentHorizontalAlignment = UIControlContentHorizontalAlignmentLeft;
        [_attachButton setHidden:YES];
        [contentView addSubview:_attachButton];
    }
    
    return self;
}

- (void)layoutSubviews {
    [super layoutSubviews];
    
    CGRect bounds = self.contentView.bounds;
    CGRect actualBounds = UIEdgeInsetsInsetRect(bounds, _contentInsets);
    CGFloat labelsOffset = 5.0f;
    
    CGSize topLabelSize = CGSizeMake(actualBounds.size.width / 2.0f, CELL_HEADER_MIN_HEIGHT);
    _userNameLabel.frame = CGRectMake(actualBounds.origin.x + labelsOffset,
                                      actualBounds.origin.y,
                                      topLabelSize.width,
                                      topLabelSize.height);
    
    _dateLabel.frame = CGRectMake(actualBounds.origin.x + actualBounds.size.width - topLabelSize.width,
                                  actualBounds.origin.y,
                                  topLabelSize.width,
                                  topLabelSize.height);
    
    BOOL hasDescription = ([_item.body length] > 0);
    BOOL hasAttachment = ([_item.attachments count] > 0);
    
    CGFloat descriptionInset = (hasAttachment) ? ATTACHMENT_VIEW_HEIGHT : 0.0f;
    CGFloat descriptionY = CGRectBottom(_userNameLabel.frame) + DESCRIPTION_Y_OFFSET;
    CGFloat descriptionHeight = (hasDescription) ? actualBounds.size.height - descriptionY - descriptionInset : 0.0f;
    
    if(hasAttachment && !hasDescription) {
        descriptionHeight = 16.5f;
    }

    _descriptionLabel.frame = CGRectMake(actualBounds.origin.x + labelsOffset,
                                         descriptionY,
                                         (hasDescription) ? actualBounds.size.width : 10.0f,
                                         descriptionHeight);
    if(hasAttachment) {
        CGSize constrainedSize = CGSizeMake(actualBounds.size.width,
                                            15.0f);
        CGSize attachmentSize = [_attachButton sizeThatFits:constrainedSize];
        
        _attachButton.frame = CGRectMake((hasAttachment && !hasDescription) ? CGRectRight(_descriptionLabel.frame) + 5.0f : _descriptionLabel.frame.origin.x,
                                         (hasAttachment && !hasDescription) ? _descriptionLabel.frame.origin.y : CGRectBottom(_descriptionLabel.frame) + 5.0f,
                                         attachmentSize.width + 5.0f,
                                         attachmentSize.height);
    }
}

- (void)setItem:(IQComment *)item {
    _item = item;
    
    BOOL commentIsMine = ([_item.author.userId isEqualToNumber:[IQSession defaultSession].userId]);
    
    _dateLabel.text = [_item.createDate dateToDayTimeString];
    _userNameLabel.hidden = ([_item.author.displayName length] == 0);
    _userNameLabel.text = _item.author.displayName;
    
    NSString * descriptionAuthor = (commentIsMine) ? [NSString stringWithFormat:@"%@:", NSLocalizedString(@"I", nil)] : @"";
    NSString * body = ([_item.body length] > 0) ? _item.body : @"";
    _descriptionLabel.text = [NSString stringWithFormat:@"%@ %@", descriptionAuthor, body];
    
    BOOL hasAttachment = ([_item.attachments count] > 0);
    [_attachButton setHidden:(!hasAttachment)];
    
    if(hasAttachment) {
        IQAttachment * attachment = [[_item.attachments allObjects] lastObject];
        [_attachButton setTitle:attachment.displayName forState:UIControlStateNormal];
    }

    [self setNeedsLayout];
}

- (void)setAuthor:(NSString *)author {
    _author = author;
    _userNameLabel.hidden = ([author length] == 0);
    _userNameLabel.text = author;
    [self setNeedsLayout];
}

- (void)prepareForReuse {
    [super prepareForReuse];
    [_attachButton removeTarget:nil
                         action:NULL
               forControlEvents:UIControlEventTouchUpInside];
}

- (UILabel*)makeLabelWithTextColor:(UIColor*)textColor font:(UIFont*)font localaizedKey:(NSString*)localaizedKey {
    UILabel * label = [[UILabel alloc] init];
    [label setFont:font];
    [label setTextColor:textColor];
    label.textAlignment = NSTextAlignmentLeft;
    label.backgroundColor = [UIColor clearColor];
    label.numberOfLines = 0;
    label.lineBreakMode = NSLineBreakByTruncatingTail;
    if(localaizedKey) {
        [label setText:NSLocalizedString(localaizedKey, nil)];
    }
    return label;
}

@end
