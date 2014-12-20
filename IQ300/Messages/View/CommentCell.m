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
#define DESCRIPTION_LEFT_TEXT_COLOR [UIColor whiteColor]
#define DESCRIPTION_RIGHT_TEXT_COLOR [UIColor colorWithHexInt:0x8b8b8b]
#define STATUS_IMAGE_SIZE 11
#define CELL_HEADER_HEIGHT 12

#define BUBBLE_WIDTH 205
#define BUBBLE_BOTTOM_OFFSET 6.0f

typedef NS_ENUM(NSInteger, CommentCellStyle) {
    CommentCellStyleLeft,
    CommentCellStyleRight
};

@interface CommentCell() {
    BOOL _commentIsMine;
    UIImageView * _bubbleImageView;
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
                          @(CommentCellStyleLeft)  : [UIImage imageNamed:@"bubble_gray.png"],
                          @(CommentCellStyleRight) : [UIImage imageNamed:@"bubble_green.png"]
                          };
    });
    
    UIImage * bubbleImage = [_bubbleImages objectForKey:@(type)];
    if(bubbleImage) {
        return [bubbleImage stretchableImageWithLeftCapWidth:5
                                                topCapHeight:5];
    }
    
    return nil;
}

+ (CGFloat)heightForItem:(IQComment *)item andCellWidth:(CGFloat)cellWidth {
    CGFloat descriptionWidth = cellWidth - CONTENT_INSET * 2.0f;
    CGFloat height = COMMENT_CELL_MIN_HEIGHT;
    
    if([item.body length] > 0) {
        CGSize descriptionSize = [item.body sizeWithFont:DESCRIPTION_LABEL_FONT
                                                   constrainedToSize:CGSizeMake(descriptionWidth, COMMENT_CELL_MAX_HEIGHT)
                                                       lineBreakMode:NSLineBreakByWordWrapping];
        height = MAX(descriptionSize.height + CELL_HEADER_HEIGHT + DESCRIPTION_PADDING * 2.0f + BUBBLE_BOTTOM_OFFSET + HEIGHT_DELTA,
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
    
    BOOL hasDescription = ([_item.body length] > 0);
    BOOL hasAttachment = ([_item.attachments count] > 0);
    CGRect bounds = self.contentView.bounds;
    CGRect actualBounds = UIEdgeInsetsInsetRect(bounds, _contentInsets);
    CGFloat bubleOffset = 5.0f;
    CGFloat bubleTailWidth = 2.0f;
 
    _timeLabel.frame = CGRectMake(actualBounds.origin.x,
                                  actualBounds.origin.y,
                                  actualBounds.size.width,
                                  7);
    
    CGFloat bubdleImageY = CGRectBottom(_timeLabel.frame) + 5.0f;

    if(_commentIsMine) {
        _statusImageView.frame = CGRectMake(actualBounds.origin.x + actualBounds.size.width - bubleOffset - BUBBLE_WIDTH - STATUS_IMAGE_SIZE,
                                            bubdleImageY + 10.0f,
                                            STATUS_IMAGE_SIZE,
                                            STATUS_IMAGE_SIZE);
    }
    else {
        _statusImageView.frame = CGRectZero;
    }
    
    CGFloat bubdleImageX = (_commentIsMine) ? CGRectRight(_statusImageView.frame) + bubleOffset : actualBounds.origin.x;
    _bubbleImageView.frame = CGRectMake(bubdleImageX,
                                        CGRectBottom(_timeLabel.frame) + 5.0f,
                                        BUBBLE_WIDTH,
                                        actualBounds.size.height - bubdleImageY - BUBBLE_BOTTOM_OFFSET);
    
    CGFloat descriptioHeight = (hasAttachment) ? _bubbleImageView.frame.size.height - ATTACHMENT_VIEW_HEIGHT - DESCRIPTION_PADDING * 2 :
                                                 _bubbleImageView.frame.size.height - DESCRIPTION_PADDING * 2;
    
    _descriptionLabel.frame = CGRectMake(_bubbleImageView.frame.origin.x + DESCRIPTION_PADDING,
                                         _bubbleImageView.frame.origin.y + DESCRIPTION_PADDING - bubleTailWidth,
                                         _bubbleImageView.frame.size.width - DESCRIPTION_PADDING * 2.0f,
                                         (hasDescription) ? descriptioHeight : 0.0f);
    
    if(hasAttachment) {
        CGSize constrainedSize = CGSizeMake(actualBounds.size.width,
                                            15.0f);
        CGSize attachmentSize = [_attachButton sizeThatFits:constrainedSize];
        
        CGFloat attachButtonY =  (hasDescription) ? CGRectBottom(_descriptionLabel.frame) + 5.0f :
                                                    _bubbleImageView.frame.origin.y + (_bubbleImageView.frame.size.height - attachmentSize.height  - bubleTailWidth) / 2;
        _attachButton.frame = CGRectMake(_descriptionLabel.frame.origin.x,
                                         attachButtonY,
                                         attachmentSize.width + 5.0f,
                                         attachmentSize.height);
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
    _descriptionLabel.text = body;
    _descriptionLabel.textColor = (_commentIsMine) ? DESCRIPTION_LEFT_TEXT_COLOR :
                                                     DESCRIPTION_RIGHT_TEXT_COLOR;
    
    BOOL hasAttachment = ([_item.attachments count] > 0);
    [_attachButton setHidden:(!hasAttachment)];
    
    if(hasAttachment) {
        IQAttachment * attachment = [[_item.attachments allObjects] lastObject];
        [_attachButton setTitle:attachment.displayName forState:UIControlStateNormal];
    }

    [self setStatus:[_item.commentStatus integerValue]];
    [_statusImageView setHidden:!_commentIsMine];
    [self setBubbleImageForStyle:(_commentIsMine) ? CommentCellStyleRight : CommentCellStyleLeft];
    
    [self setNeedsLayout];
}

- (void)prepareForReuse {
    [super prepareForReuse];
    _commentIsMine = NO;
    [self setStatus:IQCommentStatusUnknown];
    [_attachButton setHidden:YES];
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
    if(localaizedKey) {
        [label setText:NSLocalizedString(localaizedKey, nil)];
    }
    return label;
}

- (void)setBubbleImageForStyle:(CommentCellStyle)style {
    _bubbleImageView.image = [CommentCell bubbleImageForCommentStyle:style];
}

@end
