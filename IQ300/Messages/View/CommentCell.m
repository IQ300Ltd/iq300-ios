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

#define CONTENT_INSET 8.0f
#define ATTACHMENT_VIEW_HEIGHT 15.0f
#define HEIGHT_DELTA 1.0f
#define DESCRIPTION_PADDING 7
#define DESCRIPTION_LABEL_FONT [UIFont fontWithName:IQ_HELVETICA size:13]
#define DESCRIPTION_LEFT_TEXT_COLOR [UIColor colorWithHexInt:0x1d1d1d]
#define DESCRIPTION_RIGHT_TEXT_COLOR [UIColor colorWithHexInt:0x1d1d1d]
#define STATUS_IMAGE_SIZE 11
#define TIME_LABEL_HEIGHT 7.0f
#define CONTENT_Y_OFFSET 5.0f
#define CELL_HEADER_HEIGHT TIME_LABEL_HEIGHT + CONTENT_Y_OFFSET

#define BUBBLE_WIDTH 205
#define BUBBLE_BOTTOM_OFFSET 6.0f

typedef NS_ENUM(NSInteger, CommentCellStyle) {
    CommentCellStyleLeft,
    CommentCellStyleRight
};

@interface CommentCell() {
    BOOL _commentIsMine;
    UIImageView * _bubbleImageView;
    NSMutableArray * _attachButtons;
    UITapGestureRecognizer * _singleTapGesture;
}

@end

@implementation CommentCell

+ (NSString*)statusImageForStatus:(NSInteger)type {
    static NSDictionary * _statusImages = nil;
    static dispatch_once_t oncePredicate;
    dispatch_once(&oncePredicate, ^{
        _statusImages = @{
                          @(IQCommentStatusViewed)    : @"msg_viewed.png",
                          @(IQCommentStatusSent)      : @"msg_sent.png",
                          @(IQCommentStatusSendError) : @"msg_error.png"
                        };
    });
    
    if([_statusImages objectForKey:@(type)]) {
        return [_statusImages objectForKey:@(type)];
    }
    
    return nil;
}

+ (UIImage*)bubbleImageForCommentStyle:(NSInteger)type {
    static NSDictionary * _bubbleImages = nil;
    static dispatch_once_t oncePredicate;
    dispatch_once(&oncePredicate, ^{
        _bubbleImages = @{
                          @(CommentCellStyleLeft)  : [[UIImage imageNamed:@"bubble_gray.png"] stretchableImageWithLeftCapWidth:5
                                                                                                                  topCapHeight:5],
                          @(CommentCellStyleRight) : [[UIImage imageNamed:@"bubble_blue.png"] stretchableImageWithLeftCapWidth:5
                                                                                                                   topCapHeight:5]
                          };
    });
    
    UIImage * bubbleImage = [_bubbleImages objectForKey:@(type)];
    if(bubbleImage) {
        return bubbleImage;
    }
    
    return nil;
}

+ (CGFloat)heightForItem:(IQComment *)item expanded:(BOOL)expanded {
    CGFloat descriptionWidth = BUBBLE_WIDTH - DESCRIPTION_PADDING * 2.0f;
    CGFloat height = COMMENT_CELL_MIN_HEIGHT;
    
    if([item.body length] > 0) {
        UITextView * descriptionTextView = [[UITextView alloc] init];
        [descriptionTextView setFont:DESCRIPTION_LABEL_FONT];
        descriptionTextView.textContainerInset = UIEdgeInsetsZero;
        descriptionTextView.text = item.body;
        
        CGSize descriptionSize = [descriptionTextView sizeThatFits:CGSizeMake(descriptionWidth, COMMENT_CELL_MAX_HEIGHT)];
        height = MAX(ceilf(descriptionSize.height) + CELL_HEADER_HEIGHT + DESCRIPTION_PADDING * 2.0f + BUBBLE_BOTTOM_OFFSET + HEIGHT_DELTA,
                     COMMENT_CELL_MIN_HEIGHT);
        
        if (!expanded) {
            BOOL canExpand = height > COLLAPSED_COMMENT_CELL_MAX_HEIGHT;
            height = MIN(height, COLLAPSED_COMMENT_CELL_MAX_HEIGHT);

            if(canExpand) {
                height += ATTACHMENT_VIEW_HEIGHT + CONTENT_Y_OFFSET * 2.0f;
            }
        }
    }
    else {
        height = CELL_HEADER_HEIGHT + CONTENT_Y_OFFSET + BUBBLE_BOTTOM_OFFSET + HEIGHT_DELTA;
    }
    
    BOOL hasAttachment = ([item.attachments count] > 0);
    if(hasAttachment) {
        height += (ATTACHMENT_VIEW_HEIGHT + CONTENT_Y_OFFSET) * item.attachments.count;
    }
    
    return height;
}

+ (BOOL)cellNeedToBeExpandableForItem:(IQComment *)item {
    CGFloat descriptionWidth = BUBBLE_WIDTH - DESCRIPTION_PADDING * 2.0f;
    CGFloat height = COMMENT_CELL_MIN_HEIGHT;
    
    if([item.body length] > 0) {
        UITextView * descriptionTextView = [[UITextView alloc] init];
        [descriptionTextView setFont:DESCRIPTION_LABEL_FONT];
        descriptionTextView.textContainerInset = UIEdgeInsetsZero;
        descriptionTextView.text = item.body;
        
        CGSize descriptionSize = [descriptionTextView sizeThatFits:CGSizeMake(descriptionWidth, COMMENT_CELL_MAX_HEIGHT)];
        height = MAX(ceilf(descriptionSize.height) + CELL_HEADER_HEIGHT + DESCRIPTION_PADDING * 2.0f + BUBBLE_BOTTOM_OFFSET + HEIGHT_DELTA,
                     COMMENT_CELL_MIN_HEIGHT);
        
        BOOL canExpand = height > COLLAPSED_COMMENT_CELL_MAX_HEIGHT;
        return canExpand;
    }
    return NO;
}

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier {
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    
    if(self) {
        UIView * contentView = self.contentView;
        [self setBackgroundColor:[UIColor clearColor]];
        [self setSelectionStyle:UITableViewCellSelectionStyleNone];
       
        _contentInsets = UIEdgeInsetsMake(0.0f, CONTENT_INSET, 0.0f, CONTENT_INSET);
        
        _timeLabel = [self makeLabelWithTextColor:[UIColor colorWithHexInt:0xb3b3b3]
                                             font:[UIFont fontWithName:IQ_HELVETICA size:9]
                                    localaizedKey:nil];
        _timeLabel.textAlignment = NSTextAlignmentRight;
        [contentView addSubview:_timeLabel];
        
        _bubbleImageView = [UIImageView new];
        [contentView addSubview:_bubbleImageView];
        
        _statusImageView = [[UIImageView alloc] init];
        _statusImageView.contentMode = UIViewContentModeCenter;
        [_statusImageView setBackgroundColor:[UIColor clearColor]];
        [contentView addSubview:_statusImageView];
        
        _singleTapGesture = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(singleTapRecognized:)];
        _singleTapGesture.numberOfTapsRequired = 1;
        
        _descriptionTextView = [[UITextView alloc] init];
        [_descriptionTextView setFont:DESCRIPTION_LABEL_FONT];
        [_descriptionTextView setTextColor:DESCRIPTION_RIGHT_TEXT_COLOR];
        _descriptionTextView.textAlignment = NSTextAlignmentLeft;
        _descriptionTextView.backgroundColor = [UIColor clearColor];
        _descriptionTextView.editable = NO;
        _descriptionTextView.textContainerInset = UIEdgeInsetsZero;
        _descriptionTextView.scrollEnabled = NO;
        _descriptionTextView.dataDetectorTypes = UIDataDetectorTypeLink;
        _descriptionTextView.linkTextAttributes = @{
                                                    NSForegroundColorAttributeName: [UIColor colorWithHexInt:0x358bae],
                                                    NSUnderlineStyleAttributeName: @(NSUnderlineStyleSingle)
                                                    };
        
        [_descriptionTextView addGestureRecognizer:_singleTapGesture];
        [contentView addSubview:_descriptionTextView];
        
        UIColor * titleColor = [UIColor colorWithHexInt:0x4486a7];
        UIColor * titleHighlightedColor = [UIColor colorWithHexInt:0x254759];
        UIImage * bacgroundImage = [UIImage imageNamed:@"view_all_ico.png"];
        _expandButton = [[UIButton alloc] init];
        [_expandButton setImage:bacgroundImage forState:UIControlStateNormal];
        [_expandButton.titleLabel setFont:[UIFont fontWithName:IQ_HELVETICA size:11]];
        [_expandButton setTitleColor:titleColor forState:UIControlStateNormal];
        [_expandButton setTitleColor:titleHighlightedColor forState:UIControlStateHighlighted];
        [_expandButton setTitleEdgeInsets:UIEdgeInsetsMake(0.0f, 5.0f, 0.0f, 0.0f)];
       _expandButton.contentHorizontalAlignment = UIControlContentHorizontalAlignmentLeft;
        
        NSDictionary *underlineAttribute = @{
                                             NSFontAttributeName            : [UIFont fontWithName:IQ_HELVETICA size:11],
                                             NSUnderlineStyleAttributeName  : @(NSUnderlineStyleSingle),
                                             NSForegroundColorAttributeName : titleColor
                                             };
        [_expandButton setAttributedTitle:[[NSAttributedString alloc] initWithString:NSLocalizedString(@"View all", nil)
                                                                         attributes:underlineAttribute]
                                forState:UIControlStateNormal];
        
        underlineAttribute = @{
                               NSFontAttributeName            : [UIFont fontWithName:IQ_HELVETICA size:11],
                               NSUnderlineStyleAttributeName  : @(NSUnderlineStyleSingle),
                               NSForegroundColorAttributeName : titleHighlightedColor
                               };
        [_expandButton setAttributedTitle:[[NSAttributedString alloc] initWithString:NSLocalizedString(@"View all", nil)
                                                                         attributes:underlineAttribute]
                                forState:UIControlStateHighlighted];
        
        [_expandButton setHidden:YES];
        [contentView addSubview:_expandButton];
        
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
    BOOL hasExpandView = (_expandable && !_expanded);
    
    CGRect bounds = self.contentView.bounds;
    CGRect actualBounds = UIEdgeInsetsInsetRect(bounds, _contentInsets);
    CGFloat bubleOffset = 5.0f;
 
    _timeLabel.frame = CGRectMake(actualBounds.origin.x,
                                  actualBounds.origin.y,
                                  actualBounds.size.width,
                                  TIME_LABEL_HEIGHT);
    
    CGFloat bubdleImageY = CGRectBottom(_timeLabel.frame) + CONTENT_Y_OFFSET;

    if(_commentIsMine) {
        _statusImageView.frame = CGRectMake(actualBounds.origin.x + actualBounds.size.width - CONTENT_Y_OFFSET - BUBBLE_WIDTH - STATUS_IMAGE_SIZE,
                                            bubdleImageY + 10.0f,
                                            STATUS_IMAGE_SIZE,
                                            STATUS_IMAGE_SIZE);
    }
    else {
        _statusImageView.frame = CGRectZero;
    }
    
    CGFloat bubdleImageX = (_commentIsMine) ? CGRectRight(_statusImageView.frame) + bubleOffset : actualBounds.origin.x;
    _bubbleImageView.frame = CGRectMake(bubdleImageX,
                                        bubdleImageY,
                                        BUBBLE_WIDTH,
                                        actualBounds.size.height - bubdleImageY - BUBBLE_BOTTOM_OFFSET);
    
    
    CGRect contentRect = _bubbleImageView.frame;
    CGFloat expandViewHeight = (hasExpandView) ? ATTACHMENT_VIEW_HEIGHT + CONTENT_Y_OFFSET : 0.0f;
    CGFloat attachmentRectHeight = (hasAttachment) ? (ATTACHMENT_VIEW_HEIGHT + CONTENT_Y_OFFSET) * [_attachButtons count] : 0.0f;
    CGFloat descriptioHeight =  (contentRect.size.height - DESCRIPTION_PADDING * 2) - attachmentRectHeight - expandViewHeight;
    
    _descriptionTextView.frame = CGRectMake(contentRect.origin.x + DESCRIPTION_PADDING,
                                            contentRect.origin.y + DESCRIPTION_PADDING - 1,
                                            contentRect.size.width - DESCRIPTION_PADDING * 2.0f,
                                            (hasDescription) ? descriptioHeight : 0.0f);
    
    if(hasExpandView) {
        _expandButton.frame = CGRectMake(_descriptionTextView.frame.origin.x + CONTENT_Y_OFFSET,
                                         CGRectBottom(_descriptionTextView.frame) + CONTENT_Y_OFFSET,
                                         _descriptionTextView.frame.size.width - CONTENT_Y_OFFSET,
                                         ATTACHMENT_VIEW_HEIGHT);
    }
    
    if(hasAttachment) {
        CGFloat attachButtonY =  (hasDescription) ? CGRectBottom(_descriptionTextView.frame) + CONTENT_Y_OFFSET + 1 :
                                                    _bubbleImageView.frame.origin.y + CONTENT_Y_OFFSET;
        
        if(hasExpandView) {
            attachButtonY = CGRectBottom(_expandButton.frame) + CONTENT_Y_OFFSET;
        }
        
        CGSize constrainedSize = CGSizeMake(_bubbleImageView.frame.size.width, ATTACHMENT_VIEW_HEIGHT);
        CGFloat attachmentX = _descriptionTextView.frame.origin.x + 5.0f;
        for (UIButton * attachButton in _attachButtons) {
            CGSize attachmentSize = [attachButton sizeThatFits:constrainedSize];
            attachButton.frame = CGRectMake(attachmentX,
                                            attachButtonY,
                                            MIN(attachmentSize.width + 5.0f, _descriptionTextView.frame.size.width),
                                            attachmentSize.height);
            
            attachButtonY = CGRectBottom(attachButton.frame) + CONTENT_Y_OFFSET;
        }
    }
}

- (void)setExpandable:(BOOL)expandable {
    if(_expandable != expandable) {
        _expandable = expandable;
        [_expandButton setHidden:!(_expandable && !_expanded)];
        [self setNeedsDisplay];
    }
}

- (void)setExpanded:(BOOL)expanded {
    if (_expanded != expanded) {
        _expanded = expanded;
        [_expandButton setHidden:!(_expandable && !_expanded)];
        [self setNeedsDisplay];
    }
}

- (void)setStatus:(IQCommentStatus)status {
    NSString * statusImageName = [CommentCell statusImageForStatus:status];
    if([statusImageName length] > 0) {
        [_statusImageView setImage:[UIImage imageNamed:statusImageName]];
    }
    else {
        [_statusImageView setImage:nil];
    }
}

- (void)setItem:(IQComment *)item {
    _item = item;
    
    _commentIsMine = ([_item.author.userId isEqualToNumber:[IQSession defaultSession].userId]);
    
    _timeLabel.text = [_item.createDate dateToTimeString];
    _timeLabel.textAlignment = (_commentIsMine) ? NSTextAlignmentRight : NSTextAlignmentLeft;
    
    NSString * body = ([_item.body length] > 0) ? _item.body : @"";
    _descriptionTextView.text = body;
    _descriptionTextView.textColor = (_commentIsMine) ? DESCRIPTION_LEFT_TEXT_COLOR :
                                                        DESCRIPTION_RIGHT_TEXT_COLOR;
    
    BOOL hasAttachment = ([_item.attachments count] > 0);
    if(hasAttachment) {
        UIColor * titleColor = [UIColor colorWithHexInt:0x358bae];
        UIColor * titleHighlightedColor = [UIColor colorWithHexInt:0x224f60];
        UIImage * bacgroundImage = [UIImage imageNamed:@"attach_ico.png"];
        for (IQAttachment * attachment in _item.attachments) {
            UIButton * attachButton = [[UIButton alloc] init];
            [attachButton setImage:bacgroundImage forState:UIControlStateNormal];
            [attachButton.titleLabel setFont:[UIFont fontWithName:IQ_HELVETICA size:11]];
            [attachButton setTitleColor:titleColor forState:UIControlStateNormal];
            [attachButton setTitleColor:titleHighlightedColor forState:UIControlStateHighlighted];
            [attachButton setTitleEdgeInsets:UIEdgeInsetsMake(0.0f, 5.0f, 0.0f, 0.0f)];
            attachButton.contentHorizontalAlignment = UIControlContentHorizontalAlignmentLeft;

            NSDictionary *underlineAttribute = @{
                                                 NSFontAttributeName            : [UIFont fontWithName:IQ_HELVETICA size:11],
                                                 NSUnderlineStyleAttributeName  : @(NSUnderlineStyleSingle),
                                                 NSForegroundColorAttributeName : titleColor
                                                 };
            [attachButton setAttributedTitle:[[NSAttributedString alloc] initWithString:attachment.displayName
                                                                             attributes:underlineAttribute]
                                    forState:UIControlStateNormal];
            
            underlineAttribute = @{
                                   NSFontAttributeName            : [UIFont fontWithName:IQ_HELVETICA size:11],
                                   NSUnderlineStyleAttributeName  : @(NSUnderlineStyleSingle),
                                   NSForegroundColorAttributeName : titleHighlightedColor
                                   };
            [attachButton setAttributedTitle:[[NSAttributedString alloc] initWithString:attachment.displayName
                                                                             attributes:underlineAttribute]
                                    forState:UIControlStateHighlighted];

            
            [self.contentView addSubview:attachButton];
            [_attachButtons addObject:attachButton];
        }
    }

    [self setStatus:[_item.commentStatus integerValue]];
    [_statusImageView setHidden:!_commentIsMine];
    [self setBubbleImageForStyle:(_commentIsMine) ? CommentCellStyleRight : CommentCellStyleLeft];
    
    [self setNeedsLayout];
}

- (void)prepareForReuse {
    [super prepareForReuse];
    
    _commentIsMine = NO;
    _expanded = NO;
    _expandable = NO;

    _descriptionTextView.selectable = NO;
    _descriptionTextView.text = nil;
    _descriptionTextView.selectable = YES;

    [self setStatus:IQCommentStatusUnknown];
    for (UIButton * attachButton in _attachButtons) {
        [attachButton removeTarget:nil
                            action:NULL
                  forControlEvents:UIControlEventTouchUpInside];
    }
    
    [_expandButton setHidden:YES];
    [_expandButton removeTarget:nil
                         action:NULL
               forControlEvents:UIControlEventTouchUpInside];
    
    [_attachButtons makeObjectsPerformSelector:@selector(removeFromSuperview)];
    [_attachButtons removeAllObjects];
}

- (UILabel*)makeLabelWithTextColor:(UIColor*)textColor font:(UIFont*)font localaizedKey:(NSString*)localaizedKey {
    UILabel * label = [[UILabel alloc] init];
    [label setFont:font];
    [label setTextColor:textColor];
    label.textAlignment = NSTextAlignmentLeft;
    label.backgroundColor = [UIColor clearColor];
    label.numberOfLines = 0;
    if(localaizedKey) {
        [label setText:NSLocalizedString(localaizedKey, nil)];
    }
    return label;
}

- (void)setBubbleImageForStyle:(CommentCellStyle)style {
    _bubbleImageView.image = [CommentCell bubbleImageForCommentStyle:style];
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
