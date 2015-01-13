//
//  CCommentCell.m
//  IQ300
//
//  Created by Tayphoon on 24.12.14.
//  Copyright (c) 2014 Tayphoon. All rights reserved.
//
#import <QuartzCore/QuartzCore.h>

#import "CCommentCell.h"
#import "NSDate+IQFormater.h"
#import "IQBadgeView.h"
#import "IQConversation.h"
#import "IQSession.h"

#define CONTENT_INSET 8.0f
#define ATTACHMENT_VIEW_HEIGHT 15.0f
#define HEIGHT_DELTA 1.0f
#define VERTICAL_PADDING 10
#define DESCRIPTION_Y_OFFSET 3.0f
#define CELL_HEADER_MIN_HEIGHT 15
#define CONTEN_BACKGROUND_COLOR [UIColor whiteColor]
#define CONTEN_BACKGROUND_COLOR_HIGHLIGHTED [UIColor colorWithHexInt:0xe9faff]
#define DESCRIPTION_LABEL_FONT [UIFont fontWithName:IQ_HELVETICA size:13]
#define ATTACHMENT_VIEW_Y_OFFSET 7.0f

@interface CCommentCell() {
    BOOL _commentIsMine;
    NSMutableArray * _attachButtons;
    UITapGestureRecognizer * _singleTapGesture;
}

@end

@implementation CCommentCell

+ (CGFloat)heightForItem:(IQComment *)item andCellWidth:(CGFloat)cellWidth {
    CGFloat descriptionY = CELL_HEADER_MIN_HEIGHT;
    CGFloat descriptionWidth = cellWidth - CONTENT_INSET * 2.0f;
    CGFloat height = COMMENT_CELL_MIN_HEIGHT;
    
    if([item.body length] > 0) {
        CGSize descriptionSize = [item.body boundingRectWithSize:CGSizeMake(descriptionWidth, COMMENT_CELL_MAX_HEIGHT)
                                                         options:(NSStringDrawingUsesLineFragmentOrigin | NSStringDrawingUsesFontLeading)
                                                      attributes:@{NSFontAttributeName:DESCRIPTION_LABEL_FONT}
                                                         context:nil].size;
        height = MAX(descriptionY + descriptionSize.height + VERTICAL_PADDING * 2.0f + DESCRIPTION_Y_OFFSET + HEIGHT_DELTA,
                     COMMENT_CELL_MIN_HEIGHT);
    }
    else {
        height = descriptionY + VERTICAL_PADDING * 2.0f + DESCRIPTION_Y_OFFSET + HEIGHT_DELTA;
    }

    BOOL hasAttachment = ([item.attachments count] > 0);
    if(hasAttachment) {
        height += (ATTACHMENT_VIEW_HEIGHT + ATTACHMENT_VIEW_Y_OFFSET) * item.attachments.count - ATTACHMENT_VIEW_Y_OFFSET;
    }
    
    return height;
}

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier {
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    
    if(self) {
        UIView * contentView = self.contentView;
        [self setBackgroundColor:CONTEN_BACKGROUND_COLOR];
        [self setSelectionStyle:UITableViewCellSelectionStyleNone];
        
        _contentInsets = UIEdgeInsetsMake(VERTICAL_PADDING, CONTENT_INSET, 0.0f, CONTENT_INSET);
        
        _dateLabel = [self makeLabelWithTextColor:[UIColor colorWithHexInt:0xb3b3b3]
                                             font:[UIFont fontWithName:IQ_HELVETICA size:13]
                                    localaizedKey:nil];
        _dateLabel.textAlignment = NSTextAlignmentRight;
        [contentView addSubview:_dateLabel];
        
        _userNameLabel = [self makeLabelWithTextColor:[UIColor whiteColor]
                                                 font:[UIFont fontWithName:IQ_HELVETICA size:13]
                                        localaizedKey:nil];
        _userNameLabel.backgroundColor = [UIColor clearColor];
        _userNameLabel.textAlignment = NSTextAlignmentCenter;
        _userNameLabel.backgroundColor = [UIColor colorWithHexInt:0x9f9f9f];
        _userNameLabel.layer.cornerRadius = 3;
        _userNameLabel.clipsToBounds = YES;
        [contentView addSubview:_userNameLabel];
        
        _singleTapGesture = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(singleTapRecognized:)];
        _singleTapGesture.numberOfTapsRequired = 1;

        _descriptionTextView = [[UITextView alloc] init];
        [_descriptionTextView setFont:DESCRIPTION_LABEL_FONT];
        [_descriptionTextView setTextColor:[UIColor colorWithHexInt:0x8b8b8b]];
        _descriptionTextView.textAlignment = NSTextAlignmentLeft;
        _descriptionTextView.backgroundColor = [UIColor clearColor];
        _descriptionTextView.editable = NO;
        _descriptionTextView.textContainerInset = UIEdgeInsetsZero;
        _descriptionTextView.scrollEnabled = NO;
        _descriptionTextView.dataDetectorTypes = UIDataDetectorTypeLink;
        [_descriptionTextView addGestureRecognizer:_singleTapGesture];
        [contentView addSubview:_descriptionTextView];
        
        _attachButtons = [NSMutableArray array];
    }
    
    return self;
}

- (NSArray*)attachButtons {
    return [_attachButtons copy];
}

- (void)layoutSubviews {
    [super layoutSubviews];
    
    BOOL hasDescription = ([_item.body length] > 0);
    BOOL hasAttachment = ([_item.attachments count] > 0);

    CGRect bounds = self.contentView.bounds;
    CGRect actualBounds = UIEdgeInsetsInsetRect(bounds, _contentInsets);
    CGFloat labelsOffset = 5.0f;
    
    CGSize topLabelSize = CGSizeMake(actualBounds.size.width / 2.0f, CELL_HEADER_MIN_HEIGHT);
    if (([_userNameLabel.text length] > 0)) {
        CGSize userSize = [_userNameLabel.text sizeWithFont:_userNameLabel.font
                                          constrainedToSize:topLabelSize
                                              lineBreakMode:_userNameLabel.lineBreakMode];
        
        _userNameLabel.frame = CGRectMake(actualBounds.origin.x + labelsOffset,
                                          actualBounds.origin.y,
                                          userSize.width + 5,
                                          topLabelSize.height);
    }

    
    _dateLabel.frame = CGRectMake(actualBounds.origin.x + actualBounds.size.width - topLabelSize.width,
                                  actualBounds.origin.y,
                                  topLabelSize.width,
                                  topLabelSize.height);
    
    CGFloat attachmentRectHeight = (ATTACHMENT_VIEW_HEIGHT + ATTACHMENT_VIEW_Y_OFFSET) * [_attachButtons count] - ATTACHMENT_VIEW_Y_OFFSET;
    CGFloat descriptionInset = (hasAttachment) ? attachmentRectHeight : 0.0f;
    CGFloat descriptionY = CGRectBottom(_userNameLabel.frame) + DESCRIPTION_Y_OFFSET;
    CGFloat descriptionHeight = (hasDescription) ? actualBounds.size.height - descriptionY - descriptionInset : 0.0f;
    
    if(hasAttachment && !hasDescription) {
        descriptionHeight = 16.5f;
    }
    
    _descriptionTextView.frame = CGRectMake(actualBounds.origin.x + labelsOffset,
                                            descriptionY,
                                            (hasDescription) ? actualBounds.size.width : 10.0f,
                                            descriptionHeight);
    if(hasAttachment) {
        CGFloat attachmentY = (hasAttachment && !hasDescription) ? _descriptionTextView.frame.origin.y + 2.0f : CGRectBottom(_descriptionTextView.frame) + 5.0f;
        CGSize constrainedSize = CGSizeMake(actualBounds.size.width, 15.0f);
        for (UIButton * attachButton in _attachButtons) {
            CGFloat attachmentX = _descriptionTextView.frame.origin.x;
            CGSize attachmentSize = [attachButton sizeThatFits:constrainedSize];
            attachButton.frame = CGRectMake(attachmentX,
                                            attachmentY,
                                            MIN(attachmentSize.width + 5.0f, actualBounds.size.width - attachmentX),
                                            attachmentSize.height);
            
            attachmentY = CGRectBottom(attachButton.frame) + 7.0f;
        }
    }
}

- (void)setItem:(IQComment *)item {
    _item = item;
    
    _commentIsMine = ([_item.author.userId isEqualToNumber:[IQSession defaultSession].userId]);
    
    _dateLabel.text = [_item.createDate dateToDayTimeString];
    _userNameLabel.hidden = ([_item.author.displayName length] == 0);
    _userNameLabel.text = _item.author.displayName;
    
    NSString * body = ([_item.body length] > 0) ? _item.body : @"";
    _descriptionTextView.text = body;
    
    BOOL hasAttachment = ([_item.attachments count] > 0);
    
    if(hasAttachment) {
        for (IQAttachment * attachment in _item.attachments) {
            UIButton * attachButton = [[UIButton alloc] init];
            [attachButton setImage:[UIImage imageNamed:@"attach_ico.png"] forState:UIControlStateNormal];
            [attachButton.titleLabel setFont:[UIFont fontWithName:IQ_HELVETICA size:11]];
            [attachButton setTitleColor:[UIColor colorWithHexInt:0x358bae] forState:UIControlStateNormal];
            [attachButton setTitleColor:[UIColor colorWithHexInt:0x446b7a] forState:UIControlStateHighlighted];
            [attachButton setTitleEdgeInsets:UIEdgeInsetsMake(0.0f, 5.0f, 0.0f, 0.0f)];
            attachButton.contentHorizontalAlignment = UIControlContentHorizontalAlignmentLeft;
            [attachButton setTitle:attachment.displayName forState:UIControlStateNormal];
            [attachButton sizeToFit];
            [self.contentView addSubview:attachButton];
            [_attachButtons addObject:attachButton];
        }
    }
    
    [self setNeedsLayout];
}

- (void)setAuthor:(NSString *)author {
    _author = author;
    _userNameLabel.hidden = ([author length] == 0);
    _userNameLabel.text = author;
    [self setNeedsLayout];
}

- (void)setCommentHighlighted:(BOOL)commentHighlighted {
    _commentHighlighted = commentHighlighted;
    [self setBackgroundColor:(_commentHighlighted) ? CONTEN_BACKGROUND_COLOR_HIGHLIGHTED : CONTEN_BACKGROUND_COLOR];
}

- (void)prepareForReuse {
    [super prepareForReuse];
    _commentIsMine = NO;
    
    for (UIButton * attachButton in _attachButtons) {
        [attachButton removeTarget:nil
                            action:NULL
                  forControlEvents:UIControlEventTouchUpInside];
    }
    
    [_attachButtons makeObjectsPerformSelector:@selector(removeFromSuperview)];
    [_attachButtons removeAllObjects];
    [self setCommentHighlighted:NO];
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

- (void)singleTapRecognized:(UITapGestureRecognizer*)gesture {
    UITableView * tableView = [self parentTableView];
    if (tableView && [tableView.delegate respondsToSelector:@selector(tableView:didSelectRowAtIndexPath:)]) {
        [tableView.delegate tableView:tableView didSelectRowAtIndexPath:[tableView indexPathForCell:self]];
    }
}

- (UITableView *)parentTableView {
    UIView *aView = self.superview;
    while(aView != nil) {
        if([aView isKindOfClass:[UITableView class]]) {
            return (UITableView *)aView;
        }
        aView = aView.superview;
    }
    return nil;
}

@end
