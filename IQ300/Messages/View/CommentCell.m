//
//  CommentCell.m
//  IQ300
//
//  Created by Tayphoon on 04.12.14.
//  Copyright (c) 2014 Tayphoon. All rights reserved.
//
#import <QuartzCore/QuartzCore.h>
#import <SDWebImage/UIImageView+WebCache.h>

#import "CommentCell.h"
#import "NSDate+IQFormater.h"
#import "IQBadgeView.h"
#import "IQConversation.h"
#import "IQSession.h"
#import "IQAttachmentsView.h"
#import "IQLayoutManager.h"
#import "IQOnlineIndicator.h"


#define CONTENT_INSET 8.0f
#define ATTACHMENTS_VIEW_HEIGHT 120.0f

#define DESCRIPTION_PADDING 7
#define DESCRIPTION_LEFT_TEXT_COLOR IQ_FONT_GRAY_DARK_COLOR
#define DESCRIPTION_RIGHT_TEXT_COLOR IQ_FONT_GRAY_DARK_COLOR
#define STATUS_IMAGE_SIZE 11
#define TIME_LABEL_HEIGHT 7.0f
#define CONTENT_OFFSET 5.0f
#define CELL_HEADER_HEIGHT TIME_LABEL_HEIGHT + CONTENT_OFFSET

#define BUBBLE_WIDTH_PERCENT 0.66f
#define BUBBLE_BOTTOM_OFFSET 6.0f

#ifdef IPAD
#define DESCRIPTION_LABEL_FONT [UIFont fontWithName:IQ_HELVETICA size:14]
#define HEIGHT_DELTA 0.0f
#define COLLAPSED_COMMENT_CELL_MAX_HEIGHT 193.0f
#define USER_INFO_HEIGHT 27.5f
#define USER_ICON_SIZE 17.0f
#else
#define DESCRIPTION_LABEL_FONT [UIFont fontWithName:IQ_HELVETICA size:13]
#define HEIGHT_DELTA 1.0f
#define COLLAPSED_COMMENT_CELL_MAX_HEIGHT 182.0f
#define USER_INFO_HEIGHT 25.5f
#define USER_ICON_SIZE 16.0f
#endif

typedef NS_ENUM(NSInteger, CommentCellStyle) {
    CommentCellStyleLeft,
    CommentCellStyleRight
};

@interface CommentCell() {
    BOOL _commentIsMine;
    BOOL _commentIsForwarded;
    UIImageView * _bubbleImageView;
    UITapGestureRecognizer * _singleTapGesture;
    UIView * _separatorView;
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

+ (CGFloat)heightForItem:(IQComment *)item expanded:(BOOL)expanded сellWidth:(CGFloat)cellWidth {
    CGFloat bubbleWidth = ceilf((cellWidth - CONTENT_INSET * 2.0f) * BUBBLE_WIDTH_PERCENT);
    CGFloat descriptionWidth = bubbleWidth - DESCRIPTION_PADDING * 2.0f;
    CGFloat height = COMMENT_CELL_MIN_HEIGHT;
    
    CGFloat commentIsMine = ([item.author.userId isEqualToNumber:[IQSession defaultSession].userId]);
    
    if([item.body length] > 0) {
        UITextView * descriptionTextView = [[UITextView alloc] init];
        [descriptionTextView setFont:DESCRIPTION_LABEL_FONT];
        descriptionTextView.textContainerInset = UIEdgeInsetsZero;
        descriptionTextView.text = item.body;
        descriptionTextView.textContainer.lineFragmentPadding = 0;

        CGSize descriptionSize = [descriptionTextView sizeThatFits:CGSizeMake(descriptionWidth, COMMENT_CELL_MAX_HEIGHT)];
        height = MAX(ceilf(descriptionSize.height) + CELL_HEADER_HEIGHT + DESCRIPTION_PADDING * 2.0f + BUBBLE_BOTTOM_OFFSET + HEIGHT_DELTA,
                     COMMENT_CELL_MIN_HEIGHT);
        
        if (!expanded) {
            BOOL canExpand = height > COLLAPSED_COMMENT_CELL_MAX_HEIGHT;
            height = MIN(height, COLLAPSED_COMMENT_CELL_MAX_HEIGHT);

            if(canExpand) {
                height += 15.0f + CONTENT_OFFSET * 2.0f;
            }
        }
        else {
            height += 15.0f + CONTENT_OFFSET;
        }
    }
    else {
        height = CELL_HEADER_HEIGHT + CONTENT_OFFSET + BUBBLE_BOTTOM_OFFSET + HEIGHT_DELTA;
    }
    
    if(!commentIsMine) {
        height += USER_INFO_HEIGHT;
    }

    BOOL hasAttachment = ([item.attachments count] > 0);
    if(hasAttachment) {
        height += ATTACHMENTS_VIEW_HEIGHT + CONTENT_OFFSET;
    }
    
    if (item.forwardedInfo && [[item.type lowercaseString] isEqualToString:@"forward"]) {
        NSString *infoTitle = [self forwardedTitleWithDiscussableTitle:item.forwardedInfo.discussableTitle
                                                       discussableType:item.forwardedInfo.discussableType];
        
        CGSize infoTitleSize = [infoTitle sizeWithFont:[UIFont fontWithName:IQ_HELVETICA size:(IS_IPAD) ? 10.0f : 9.0f]];
        infoTitleSize.height += infoTitleSize.width > descriptionWidth ? infoTitleSize.height : 0;
        
        height += infoTitleSize.height + 5.f;
    }
    
    return height;
}

+ (NSString *)forwardedTitleWithDiscussableTitle:(NSString *)title discussableType:(NSString *)type {
    NSString *adaptiveTypeString = [type lowercaseString];
    
    NSString *from = @"from the dialogue";
    if ([adaptiveTypeString isEqualToString:@"base_task"]) {
        from = @"from the task";
    }
    else if ([adaptiveTypeString isEqualToString:@"conference"]) {
        from = @"from the conference";
    }
    
    return [NSString stringWithFormat:@"%@ %@: %@",
            NSLocalizedString(@"Forwarded message", nil),
            NSLocalizedString(from, nil),
            title];
}

+ (BOOL)cellNeedToBeExpandableForItem:(IQComment *)item сellWidth:(CGFloat)cellWidth {
    CGFloat bubbleWidth = ceilf((cellWidth - CONTENT_INSET * 2.0f) * BUBBLE_WIDTH_PERCENT);
    CGFloat descriptionWidth = bubbleWidth - DESCRIPTION_PADDING * 2.0f;
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
        
        _timeLabel = [self makeLabelWithTextColor:IQ_FONT_GRAY_COLOR
                                             font:[UIFont fontWithName:IQ_HELVETICA size:(IS_IPAD) ? 10.0f : 9.0f]
                                    localaizedKey:nil];
        _timeLabel.textAlignment = NSTextAlignmentRight;
        [contentView addSubview:_timeLabel];
        
        _bubbleImageView = [UIImageView new];
        [contentView addSubview:_bubbleImageView];
        
        _forwardInfoLabel = [self makeLabelWithTextColor:IQ_FONT_GRAY_COLOR
                                                    font:[UIFont fontWithName:IQ_HELVETICA size:(IS_IPAD) ? 10.0f : 9.0f]
                                           localaizedKey:nil];
        _forwardInfoLabel.numberOfLines = 0;
        [contentView addSubview:_forwardInfoLabel];
        
        _userImageView = [[UIImageView alloc] init];
        _userImageView.layer.cornerRadius = USER_ICON_SIZE / 2.0f;
        [_userImageView setImage:[UIImage imageNamed:@"user_icon.png"]];
        [_userImageView setClipsToBounds:YES];
        [contentView addSubview:_userImageView];
        
        _userNameLabel = [self makeLabelWithTextColor:IQ_FONT_GRAY_DARK_COLOR
                                             font:[UIFont fontWithName:IQ_HELVETICA size:(IS_IPAD) ? 14.0f : 13.0f]
                                    localaizedKey:nil];
        [contentView addSubview:_userNameLabel];
        
        _separatorView = [[UIView alloc] init];
        _separatorView.backgroundColor = [UIColor whiteColor];
        _separatorView.clipsToBounds = YES;
        [contentView addSubview:_separatorView];
        
        _statusImageView = [[UIImageView alloc] init];
        _statusImageView.contentMode = UIViewContentModeCenter;
        [_statusImageView setBackgroundColor:[UIColor clearColor]];
        [contentView addSubview:_statusImageView];
        
        _singleTapGesture = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(singleTapRecognized:)];
        _singleTapGesture.numberOfTapsRequired = 1;
        
        _descriptionTextView = [[IQTextView alloc] init];
        [_descriptionTextView setFont:DESCRIPTION_LABEL_FONT];
        [_descriptionTextView setTextColor:DESCRIPTION_RIGHT_TEXT_COLOR];
        _descriptionTextView.textAlignment = NSTextAlignmentLeft;
        _descriptionTextView.textContainer.lineFragmentPadding = 0;
        _descriptionTextView.backgroundColor = [UIColor clearColor];
        _descriptionTextView.editable = NO;
        _descriptionTextView.textContainerInset = UIEdgeInsetsZero;
        _descriptionTextView.scrollEnabled = NO;
        _descriptionTextView.dataDetectorTypes = UIDataDetectorTypeLink | UIDataDetectorTypePhoneNumber;
        _descriptionTextView.linkTextAttributes = @{
                                                    NSForegroundColorAttributeName : IQ_BLUE_COLOR,
                                                    NSUnderlineStyleAttributeName  : @(NSUnderlineStyleSingle)
                                                    };
        
        [_descriptionTextView addGestureRecognizer:_singleTapGesture];
        [contentView addSubview:_descriptionTextView];
        
        CGFloat expendFontSize = (IS_IPAD) ? 12 : 11.0f;
        UIColor * titleColor = IQ_CELADON_COLOR_HIGHLIGHTED;
        UIColor * titleHighlightedColor = IQ_CELADON_COLOR;
        _expandButton = [[UIButton alloc] init];
        [_expandButton setImage:[UIImage imageNamed:@"view_all_ico.png"] forState:UIControlStateNormal];
        [_expandButton setImage:[UIImage imageNamed:@"view_all_ico_highlighted.png"] forState:UIControlStateHighlighted];
        [_expandButton.titleLabel setFont:[UIFont fontWithName:IQ_HELVETICA size:expendFontSize]];
        [_expandButton setTitleColor:titleColor forState:UIControlStateNormal];
        [_expandButton setTitleColor:titleHighlightedColor forState:UIControlStateHighlighted];
        [_expandButton setTitleEdgeInsets:UIEdgeInsetsMake(0.0f, 5.0f, 0.0f, 0.0f)];
        _expandButton.contentHorizontalAlignment = UIControlContentHorizontalAlignmentLeft;
        
        NSDictionary *underlineAttribute = @{
                                             NSFontAttributeName            : [UIFont fontWithName:IQ_HELVETICA size:expendFontSize],
                                             NSUnderlineStyleAttributeName  : @(NSUnderlineStyleSingle),
                                             NSForegroundColorAttributeName : titleColor
                                             };
        [_expandButton setAttributedTitle:[[NSAttributedString alloc] initWithString:NSLocalizedString(@"Show all", nil)
                                                                         attributes:underlineAttribute]
                                forState:UIControlStateNormal];
        
        underlineAttribute = @{
                               NSFontAttributeName            : [UIFont fontWithName:IQ_HELVETICA size:expendFontSize],
                               NSUnderlineStyleAttributeName  : @(NSUnderlineStyleSingle),
                               NSForegroundColorAttributeName : titleHighlightedColor
                               };
        [_expandButton setAttributedTitle:[[NSAttributedString alloc] initWithString:NSLocalizedString(@"Show all", nil)
                                                                         attributes:underlineAttribute]
                                forState:UIControlStateHighlighted];
        
        [_expandButton setHidden:YES];
        [contentView addSubview:_expandButton];
        
        _attachmentsView = [[IQAttachmentsView alloc] initWithFrame:CGRectZero];
        [contentView addSubview:_attachmentsView];
        
        _onlineIndicator = [[IQOnlineIndicator alloc] init];
        _onlineIndicator.hidden = YES;
        [contentView addSubview:_onlineIndicator];

    }
    
    return self;
}

- (NSArray*)attachButtons {
    return [_attachmentsView attachmentButtons];
}

- (void)layoutSubviews {
    [super layoutSubviews];
    
    CGRect actualBounds = UIEdgeInsetsInsetRect(self.contentView.bounds, _contentInsets);
    CGFloat maxContentWidth = ceilf(actualBounds.size.width * BUBBLE_WIDTH_PERCENT);
    
    _timeLabel.frame = CGRectMake(CGRectGetMinX(actualBounds) + (!_commentIsMine ?: -3.f),
                                  CGRectGetMinY(actualBounds),
                                  CGRectGetWidth(actualBounds),
                                  TIME_LABEL_HEIGHT);
    
    CGPoint bubblePoint = CGPointMake(_commentIsMine ? CGRectGetMaxX(actualBounds) - maxContentWidth : CGRectGetMinX(actualBounds),
                                      CGRectGetMaxY(_timeLabel.frame) + CONTENT_OFFSET);
    
    CGSize bubbleSize = CGSizeMake(maxContentWidth,
                                   CGRectGetHeight(actualBounds) - bubblePoint.y - BUBBLE_BOTTOM_OFFSET);
    
    _bubbleImageView.frame = CGRectMake(bubblePoint.x,
                                        bubblePoint.y,
                                        bubbleSize.width,
                                        bubbleSize.height);
    
    _statusImageView.frame = CGRectZero;
    if (_commentIsMine) {
        CGFloat statusCheckPadding = 8.f;
        _statusImageView.frame = CGRectMake(bubblePoint.x - (STATUS_IMAGE_SIZE + CONTENT_OFFSET),
                                            bubblePoint.y + statusCheckPadding,
                                            STATUS_IMAGE_SIZE,
                                            STATUS_IMAGE_SIZE);
    }
    
    CGFloat tailWidth = 2.f;
    CGFloat maxTextWidth = bubbleSize.width - DESCRIPTION_PADDING * 2.f - tailWidth;
    
    CGPoint contentPoint = CGPointMake(bubblePoint.x  + (!_commentIsMine ? tailWidth : 0) + DESCRIPTION_PADDING,
                                       bubblePoint.y);
    
    _forwardInfoLabel.frame = CGRectZero;
    if (_commentIsForwarded) {
        CGSize infoTitleSize = [_forwardInfoLabel.text sizeWithFont:_forwardInfoLabel.font];
        infoTitleSize.height += infoTitleSize.width > maxTextWidth ? infoTitleSize.height : 0.f;
        infoTitleSize.width = maxTextWidth;
        
        _forwardInfoLabel.frame = CGRectMake(contentPoint.x,
                                             contentPoint.y + CONTENT_OFFSET,
                                             infoTitleSize.width,
                                             infoTitleSize.height);
        
        contentPoint.y = CGRectGetMaxY(_forwardInfoLabel.frame);
    }
    
    _userImageView.frame = CGRectZero;
    _userNameLabel.frame = CGRectZero;
    _onlineIndicator.frame = CGRectZero;
    _separatorView.frame = CGRectZero;
    
    if (!_commentIsMine) {
        _userImageView.frame = CGRectMake(contentPoint.x,
                                          contentPoint.y + (USER_INFO_HEIGHT / 2.f - USER_ICON_SIZE / 2.f),
                                          USER_ICON_SIZE,
                                          USER_ICON_SIZE);
        
        CGFloat nameMinX = CGRectGetMaxX(_userImageView.frame) + DESCRIPTION_PADDING;
        CGSize nameSize = [_userNameLabel sizeThatFits:CGSizeMake(bubbleSize.width - nameMinX - DESCRIPTION_PADDING - ONLINE_INDICATOR_LEFT_OFFSET - ONLINE_INDICATOR_SIZE,
                                                                  CGFLOAT_MAX)];
        
        _userNameLabel.frame = CGRectMake(nameMinX,
                                          CGRectGetMidY(_userImageView.frame) - nameSize.height / 2.f,
                                          nameSize.width,
                                          nameSize.height);
        
        _onlineIndicator.frame = CGRectMake(CGRectGetMaxX(_userNameLabel.frame) + ONLINE_INDICATOR_LEFT_OFFSET,
                                            CGRectGetMidY(_userNameLabel.frame) - ONLINE_INDICATOR_SIZE / 2.f,
                                            ONLINE_INDICATOR_SIZE,
                                            ONLINE_INDICATOR_SIZE);
        
        CGFloat separatorHeight = 2.0f / [UIScreen mainScreen].scale;
        _separatorView.frame = CGRectMake(bubblePoint.x,
                                          contentPoint.y + USER_INFO_HEIGHT - separatorHeight,
                                          bubbleSize.width,
                                          separatorHeight);
        
        contentPoint.y = CGRectGetMaxY(_separatorView.frame);
    }
    
    contentPoint.y += CONTENT_OFFSET;
    
    CGSize expandRectSize = CGSizeMake((IS_IPAD) ? 100.0f : 90.0f,
                                       _expandable ? 15.f + CONTENT_OFFSET : 0.f);
    
    BOOL showAttachments = [_item.attachments count] > 0;
    CGSize attachmentRectSize = CGSizeMake(maxTextWidth,
                                           showAttachments ? ATTACHMENTS_VIEW_HEIGHT + CONTENT_OFFSET : 0.f);
    
    BOOL showDescription = _descriptionTextView.text && _descriptionTextView.text.length;
    _descriptionTextView.frame = CGRectZero;
    if (showDescription) {
        CGSize descriptionSize = CGSizeMake(maxTextWidth,
                                            (bubbleSize.height - contentPoint.y) - expandRectSize.height - attachmentRectSize.height);
        
        _descriptionTextView.frame = CGRectMake(contentPoint.x,
                                                contentPoint.y,
                                                descriptionSize.width,
                                                descriptionSize.height + 2.f);
        
        contentPoint.y = CGRectGetMaxY(_descriptionTextView.frame);
    }

    _expandButton.frame = CGRectZero;
    if(_expandable) {
        _expandButton.frame = CGRectMake(contentPoint.x,
                                         contentPoint.y,
                                         expandRectSize.width,
                                         15.f);
        
        contentPoint.y = CGRectGetMaxY(_expandButton.frame) + CONTENT_OFFSET;
    }
    
    _attachmentsView.frame = CGRectZero;
    if (showAttachments) {
        _attachmentsView.frame = CGRectMake(contentPoint.x,
                                            contentPoint.y,
                                            attachmentRectSize.width,
                                            ATTACHMENTS_VIEW_HEIGHT);
    }
}

- (void)setExpandable:(BOOL)expandable {
    if(_expandable != expandable) {
        _expandable = expandable;
        [_expandButton setHidden:!_expandable];
        [self setNeedsDisplay];
    }
}

- (void)setExpanded:(BOOL)expanded {
    if (_expanded != expanded) {
        _expanded = expanded;
        
        [self setExpandButtonTitle:(_expanded) ? @"Hide" : @"Show all"];
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
    _commentIsForwarded = [item.type isEqualToString:@"forward"];
    
    _timeLabel.text = [_item.createDate dateToTimeString];
    _timeLabel.textAlignment = (_commentIsMine) ? NSTextAlignmentRight : NSTextAlignmentLeft;
    
    if (!_commentIsMine) {
        _userImageView.hidden = NO;
        _userNameLabel.hidden = NO;
        _separatorView.hidden = NO;
        _onlineIndicator.hidden = NO;

        _userNameLabel.text = _item.author.displayName;
        _onlineIndicator.online = _item.author.online.boolValue;
        if ([_item.author.thumbUrl length] > 0) {
            [_userImageView sd_setImageWithURL:[NSURL URLWithString:_item.author.thumbUrl]];
        }
        else {
            [_userImageView setImage:[UIImage imageNamed:@"user_icon.png"]];
        }
    }
    
    if (_commentIsForwarded) {
        _forwardInfoLabel.text = [CommentCell forwardedTitleWithDiscussableTitle:item.forwardedInfo.discussableTitle
                                                                 discussableType:item.forwardedInfo.discussableType];
    }
    
    _descriptionTextView.attributedText = [self formatedTextFromText:_item.body];
    
    if (item.attachments.count > 0) {
        [_attachmentsView setItems:[_item.attachments allObjects] isMine:_commentIsMine];
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
    
    _userImageView.hidden = YES;
    _userNameLabel.hidden = YES;
    _separatorView.hidden = YES;
    _onlineIndicator.hidden = YES;

    _descriptionTextView.delegate = nil;
    _descriptionTextView.selectable = NO;
    _descriptionTextView.text = nil;
    _descriptionTextView.selectable = YES;
    [_descriptionTextView setTextColor:DESCRIPTION_RIGHT_TEXT_COLOR];

    [self setStatus:IQCommentStatusUnknown];
    
    [_attachmentsView setItems:nil isMine:NO];
    
    [self setExpandButtonTitle:@"Show all"];
    [_expandButton setHidden:YES];
    [_expandButton removeTarget:nil
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

- (void)setExpandButtonTitle:(NSString*)title {
    CGFloat expandFontSize = (IS_IPAD) ? 12 : 11.0f;
    UIColor * titleColor = IQ_CELADON_COLOR_HIGHLIGHTED;
    UIColor * titleHighlightedColor = IQ_CELADON_COLOR;
    NSDictionary *underlineAttribute = @{
                                         NSFontAttributeName            : [UIFont fontWithName:IQ_HELVETICA size:expandFontSize],
                                         NSUnderlineStyleAttributeName  : @(NSUnderlineStyleSingle),
                                         NSForegroundColorAttributeName : titleColor
                                         };
    [_expandButton setAttributedTitle:[[NSAttributedString alloc] initWithString:NSLocalizedString(title, nil)
                                                                      attributes:underlineAttribute]
                             forState:UIControlStateNormal];
    
    underlineAttribute = @{
                           NSFontAttributeName            : [UIFont fontWithName:IQ_HELVETICA size:expandFontSize],
                           NSUnderlineStyleAttributeName  : @(NSUnderlineStyleSingle),
                           NSForegroundColorAttributeName : titleHighlightedColor
                           };
    [_expandButton setAttributedTitle:[[NSAttributedString alloc] initWithString:NSLocalizedString(title, nil)
                                                                      attributes:underlineAttribute]
                             forState:UIControlStateHighlighted];
    
}

- (NSAttributedString *)formatedTextFromText:(NSString *)text {
    if([text length] > 0) {
        NSError * error = nil;
        
        UIColor * textColor = (_commentIsMine) ? DESCRIPTION_RIGHT_TEXT_COLOR : DESCRIPTION_LEFT_TEXT_COLOR;
        NSDictionary * attributes = @{
                                      NSForegroundColorAttributeName : textColor,
                                      NSFontAttributeName            : DESCRIPTION_LABEL_FONT
                                      };
        
        NSMutableAttributedString * aText = [[NSMutableAttributedString alloc] initWithString:text
                                                                                   attributes:attributes];
        
        NSRegularExpression * regex = [NSRegularExpression regularExpressionWithPattern:@"(?:^|\\s)(?:@)(\\w+)" options:0 error:&error];
        NSArray * matches = [regex matchesInString:text options:0 range:NSMakeRange(0, text.length)];
        for (NSTextCheckingResult *match in matches) {
            NSRange wordRange = [match rangeAtIndex:1];
            NSString * nickName = [text substringWithRange:wordRange];
            
            if([_avalibleNicks containsObject:nickName]) {
                BOOL isCurUserNick = ([nickName isEqualToString:_currentUserNick]);
                
                wordRange.location = wordRange.location - 1;
                wordRange.length = wordRange.length + 1;
                
                if (_commentIsMine) {
                    NSDictionary * highlightAttribute = @{ IQNikStrokeColorAttributeName : IQ_BACKGROUND_P2_COLOR };
                    [aText addAttributes:@{ IQNikHighlightAttributeName    : highlightAttribute,
                                            NSForegroundColorAttributeName : IQ_BACKGROUND_P2_COLOR }
                                   range:wordRange];
                }
                else {
                    if (isCurUserNick) {
                        NSDictionary * highlightAttribute = @{ IQNikBackgroundColorAttributeName : IQ_BLUE_LIGHT_COLOR };
                        [aText addAttributes:@{ IQNikHighlightAttributeName   : highlightAttribute,
                                                NSForegroundColorAttributeName: IQ_BACKGROUND_P2_COLOR }
                                       range:wordRange];
                    }
                    else {
                        NSDictionary * highlightAttribute = @{ IQNikStrokeColorAttributeName : IQ_BACKGROUND_P2_COLOR };
                        [aText addAttributes:@{ IQNikHighlightAttributeName    : highlightAttribute,
                                                NSForegroundColorAttributeName : IQ_BACKGROUND_P2_COLOR }
                                       range:wordRange];
                    }
                }
            }
        }

        
        //add links to pattern task#taskId

        NSString * pattern = [NSString stringWithFormat:@"%@#\\d+$", NSLocalizedString(@"Task", nil)];
        regex = [NSRegularExpression regularExpressionWithPattern:pattern options:NSRegularExpressionCaseInsensitive error:&error];
        matches = [regex matchesInString:text options:0 range:NSMakeRange(0, text.length)];
        for (NSTextCheckingResult *match in matches) {
            NSRange wordRange = [match range];
            NSString * taskLink = [text substringWithRange:wordRange];
            NSString * taskId = [[taskLink componentsSeparatedByString:@"#"] lastObject];
            
            if ([taskId length] > 0) {
                [aText addAttribute:NSLinkAttributeName
                              value:[NSString stringWithFormat:@"%@://tasks/%@", APP_URL_SCHEME, taskId]
                              range:wordRange];
            }
        }
        
        return aText;
    }
    
    return nil;
}

@end
