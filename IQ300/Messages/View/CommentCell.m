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

#define CONTENT_INSET 8.0f
#define ATTACHMENTS_VIEW_HEIGHT 110.0f

#define DESCRIPTION_PADDING 7
#define DESCRIPTION_LEFT_TEXT_COLOR [UIColor colorWithHexInt:0x1d1d1d]
#define DESCRIPTION_RIGHT_TEXT_COLOR [UIColor colorWithHexInt:0x1d1d1d]
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
#define USER_ICON_SEZE 17.0f
#else
#define DESCRIPTION_LABEL_FONT [UIFont fontWithName:IQ_HELVETICA size:13]
#define HEIGHT_DELTA 1.0f
#define COLLAPSED_COMMENT_CELL_MAX_HEIGHT 182.0f
#define USER_INFO_HEIGHT 25.5f
#define USER_ICON_SEZE 16.0f
#endif

typedef NS_ENUM(NSInteger, CommentCellStyle) {
    CommentCellStyleLeft,
    CommentCellStyleRight
};

@interface CommentCell() {
    BOOL _commentIsMine;
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
    
    return height;
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
        
        _timeLabel = [self makeLabelWithTextColor:[UIColor colorWithHexInt:0xb3b3b3]
                                             font:[UIFont fontWithName:IQ_HELVETICA size:(IS_IPAD) ? 10.0f : 9.0f]
                                    localaizedKey:nil];
        _timeLabel.textAlignment = NSTextAlignmentRight;
        [contentView addSubview:_timeLabel];
        
        _bubbleImageView = [UIImageView new];
        [contentView addSubview:_bubbleImageView];
        
        _userImageView = [[UIImageView alloc] init];
        _userImageView.layer.cornerRadius = USER_ICON_SEZE / 2.0f;
        [_userImageView setImage:[UIImage imageNamed:@"user_icon.png"]];
        [_userImageView setClipsToBounds:YES];
        [contentView addSubview:_userImageView];
        
        _userNameLabel = [self makeLabelWithTextColor:DESCRIPTION_LEFT_TEXT_COLOR
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
        
        _descriptionTextView = [[UITextView alloc] init];
        [_descriptionTextView setFont:DESCRIPTION_LABEL_FONT];
        [_descriptionTextView setTextColor:DESCRIPTION_RIGHT_TEXT_COLOR];
        _descriptionTextView.textAlignment = NSTextAlignmentLeft;
        _descriptionTextView.textContainer.lineFragmentPadding = 0;
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
        
        CGFloat expendFontSize = (IS_IPAD) ? 12 : 11.0f;
        UIColor * titleColor = [UIColor colorWithHexInt:0x4486a7];
        UIColor * titleHighlightedColor = [UIColor colorWithHexInt:0x254759];
        UIImage * bacgroundImage = [UIImage imageNamed:@"view_all_ico.png"];
        _expandButton = [[UIButton alloc] init];
        [_expandButton setImage:bacgroundImage forState:UIControlStateNormal];
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
    }
    
    return self;
}

- (NSArray*)attachButtons {
    return [_attachmentsView attachmentButtons];
}

- (void)layoutSubviews {
    [super layoutSubviews];
    
    BOOL hasDescription = ([_item.body length] > 0);
    BOOL hasAttachment = ([_item.attachments count] > 0);
    BOOL hasExpandView = (_expandable);
    
    CGRect bounds = self.contentView.bounds;
    CGRect actualBounds = UIEdgeInsetsInsetRect(bounds, _contentInsets);
    CGFloat bubleOffset = 5.0f;
    CGFloat bubbleWidth = ceilf(actualBounds.size.width * BUBBLE_WIDTH_PERCENT);

    _timeLabel.frame = CGRectMake(actualBounds.origin.x,
                                  actualBounds.origin.y,
                                  actualBounds.size.width,
                                  TIME_LABEL_HEIGHT);
    
    CGFloat bubdleImageY = CGRectBottom(_timeLabel.frame) + CONTENT_OFFSET;

    if(_commentIsMine) {
        _statusImageView.frame = CGRectMake(actualBounds.origin.x + actualBounds.size.width - CONTENT_OFFSET - bubbleWidth - STATUS_IMAGE_SIZE,
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
                                        bubbleWidth,
                                        actualBounds.size.height - bubdleImageY - BUBBLE_BOTTOM_OFFSET);
    
    
    CGRect contentRect = _bubbleImageView.frame;
    
    if (!_commentIsMine) {
        CGSize userImageSize = CGSizeMake(USER_ICON_SEZE, USER_ICON_SEZE);
        _userImageView.frame = CGRectMake(contentRect.origin.x + DESCRIPTION_PADDING,
                                          contentRect.origin.y + (USER_INFO_HEIGHT - userImageSize.height - 2.0f) / 2.0f,
                                          userImageSize.width,
                                          userImageSize.height);
        
        CGFloat userNameX = CGRectRight(_userImageView.frame) + DESCRIPTION_PADDING;
        _userNameLabel.frame = CGRectMake(CGRectRight(_userImageView.frame) + DESCRIPTION_PADDING,
                                          _userImageView.frame.origin.y,
                                          contentRect.size.width - userNameX - DESCRIPTION_PADDING,
                                          _userImageView.frame.size.height);
        
        CGFloat separatorHeight = 2.0f;
        _separatorView.frame = CGRectMake(contentRect.origin.x,
                                          contentRect.origin.y + USER_INFO_HEIGHT - separatorHeight,
                                          contentRect.size.width,
                                          separatorHeight / [UIScreen mainScreen].scale);
        
        contentRect.origin.y += USER_INFO_HEIGHT;
        contentRect.size.height -= USER_INFO_HEIGHT;
    }
    
    CGFloat expandViewHeight = (hasExpandView) ? 15.0f + CONTENT_OFFSET : 0.0f;
    CGFloat attachmentRectHeight = (hasAttachment) ? ATTACHMENTS_VIEW_HEIGHT + CONTENT_OFFSET : 0.0f;
    CGFloat descriptioHeight =  (contentRect.size.height - DESCRIPTION_PADDING * 2) - attachmentRectHeight - expandViewHeight;
    
    _descriptionTextView.frame = CGRectMake(contentRect.origin.x + DESCRIPTION_PADDING,
                                            contentRect.origin.y + DESCRIPTION_PADDING - 1,
                                            contentRect.size.width - DESCRIPTION_PADDING * 2.0f,
                                            (hasDescription) ? descriptioHeight : 0.0f);
    
    if(hasExpandView) {
        _expandButton.frame = CGRectMake(_descriptionTextView.frame.origin.x + CONTENT_OFFSET,
                                         CGRectBottom(_descriptionTextView.frame) + CONTENT_OFFSET,
                                         (IS_IPAD) ? 100.0f : 90.0f,
                                         15.0f);
    }
    
    if(hasAttachment) {
        CGFloat attachmentX = _descriptionTextView.frame.origin.x;
        CGFloat attachButtonY =  (hasDescription) ? CGRectBottom(_descriptionTextView.frame) + CONTENT_OFFSET :
        contentRect.origin.y + CONTENT_OFFSET;
        
        if(hasExpandView) {
            attachButtonY = CGRectBottom(_expandButton.frame) + CONTENT_OFFSET;
        }
        
        [_attachmentsView setFrame:CGRectMake(attachmentX, attachButtonY, _descriptionTextView.frame.size.width, ATTACHMENTS_VIEW_HEIGHT)];
    }
    else {
        [_attachmentsView setFrame:CGRectZero];
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
    
    _timeLabel.text = [_item.createDate dateToTimeString];
    _timeLabel.textAlignment = (_commentIsMine) ? NSTextAlignmentRight : NSTextAlignmentLeft;
    
    if (!_commentIsMine) {
        _userImageView.hidden = NO;
        _userNameLabel.hidden = NO;
        _separatorView.hidden = NO;

        _userNameLabel.text = _item.author.displayName;
        if ([_item.author.thumbUrl length] > 0) {
            [_userImageView sd_setImageWithURL:[NSURL URLWithString:_item.author.thumbUrl]];
        }
        else {
            [_userImageView setImage:[UIImage imageNamed:@"user_icon.png"]];
        }
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
    UIColor * titleColor = [UIColor colorWithHexInt:0x4486a7];
    UIColor * titleHighlightedColor = [UIColor colorWithHexInt:0x254759];
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

- (NSAttributedString*)formatedTextFromText:(NSString*)text {
    if([text length] > 0) {
        UIColor * textColor = (_commentIsMine) ? DESCRIPTION_LEFT_TEXT_COLOR :
                                                 DESCRIPTION_RIGHT_TEXT_COLOR;
        NSDictionary * attributes = @{
                                      NSForegroundColorAttributeName : textColor,
                                      NSFontAttributeName            : DESCRIPTION_LABEL_FONT
                                      };
        
        NSMutableAttributedString * aText = [[NSMutableAttributedString alloc] initWithString:text
                                                                                   attributes:attributes];
                
        //add links to pattern task#taskId
        NSError * error = nil;
        NSString * pattern = [NSString stringWithFormat:@"%@#\\d+$", NSLocalizedString(@"Task", nil)];
        NSRegularExpression * regex = [NSRegularExpression regularExpressionWithPattern:pattern options:NSRegularExpressionCaseInsensitive error:&error];
        NSArray * matches = [regex matchesInString:text options:0 range:NSMakeRange(0, text.length)];
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
