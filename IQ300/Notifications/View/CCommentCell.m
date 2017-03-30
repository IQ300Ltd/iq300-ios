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
#import "IQAttachmentsView.h"
#import "IQOnlineIndicator.h"

#define CONTENT_INSET 8.0f
#define ATTACHMENTS_VIEW_HEIGHT 120.0f
#define VERTICAL_PADDING 10
#define DESCRIPTION_Y_OFFSET 3.0f
#define CONTEN_BACKGROUND_COLOR [UIColor whiteColor]
#define CONTEN_BACKGROUND_COLOR_HIGHLIGHTED IQ_BACKGROUND_P3_COLOR
#define NEW_FLAG_COLOR IQ_BACKGROUND_P1_COLOR
#define NEW_FLAG_WIDTH 4.0f

#ifdef IPAD
#define DEFAULT_FONT_SIZE 14
#define HEIGHT_DELTA 3.5f
#define CELL_HEADER_MIN_HEIGHT 19
#define ATTACHMENT_VIEW_Y_OFFSET 10.0f
#else
#define DEFAULT_FONT_SIZE 13
#define HEIGHT_DELTA 1.0f
#define CELL_HEADER_MIN_HEIGHT 17
#define ATTACHMENT_VIEW_Y_OFFSET 7.0f
#endif

@interface CCommentCell() {
    BOOL _commentIsMine;
    UITapGestureRecognizer * _singleTapGesture;
}

@end

@implementation CCommentCell

+ (CGFloat)heightForItem:(IQComment *)item expanded:(BOOL)expanded andCellWidth:(CGFloat)cellWidth {
    CGFloat descriptionY = CELL_HEADER_MIN_HEIGHT;
    CGFloat descriptionWidth = cellWidth - CONTENT_INSET * 2.0f;
    CGFloat height = COMMENT_CELL_MIN_HEIGHT;
    
    if([item.body length] > 0) {
        UITextView * descriptionTextView = [[UITextView alloc] init];
        [descriptionTextView setFont:DESCRIPTION_LABEL_FONT];
        descriptionTextView.textContainerInset = UIEdgeInsetsZero;
        descriptionTextView.text = item.body;
        
        CGSize descriptionSize = [descriptionTextView sizeThatFits:CGSizeMake(descriptionWidth, COMMENT_CELL_MAX_HEIGHT)];
        height = MAX(descriptionY + ceilf(descriptionSize.height) + VERTICAL_PADDING * 2.0f + DESCRIPTION_Y_OFFSET + HEIGHT_DELTA,
                     COMMENT_CELL_MIN_HEIGHT);
        if (!expanded) {
            BOOL canExpand = height > COLLAPSED_COMMENT_CELL_MAX_HEIGHT;
            height = MIN(height, COLLAPSED_COMMENT_CELL_MAX_HEIGHT);
            
            if(canExpand) {
                height += 15.0f + ATTACHMENT_VIEW_Y_OFFSET;
            }
        }
        else {
            height += 15.0f + ATTACHMENT_VIEW_Y_OFFSET;
        }
    }
    else {
        height = descriptionY + VERTICAL_PADDING * 2.0f + DESCRIPTION_Y_OFFSET + HEIGHT_DELTA;
    }

    BOOL hasAttachment = ([item.attachments count] > 0);
    if(hasAttachment) {
        height += ATTACHMENTS_VIEW_HEIGHT + ATTACHMENT_VIEW_Y_OFFSET;
    }
    
    return height;
}

+ (BOOL)cellNeedToBeExpandableForItem:(IQComment *)item andCellWidth:(CGFloat)cellWidth {
    CGFloat descriptionY = CELL_HEADER_MIN_HEIGHT;
    CGFloat descriptionWidth = cellWidth - CONTENT_INSET * 2.0f;
    CGFloat height = COMMENT_CELL_MIN_HEIGHT;
    
    if([item.body length] > 0) {
        UITextView * descriptionTextView = [[UITextView alloc] init];
        [descriptionTextView setFont:DESCRIPTION_LABEL_FONT];
        descriptionTextView.textContainerInset = UIEdgeInsetsZero;
        descriptionTextView.text = item.body;
        
        CGSize descriptionSize = [descriptionTextView sizeThatFits:CGSizeMake(descriptionWidth, COMMENT_CELL_MAX_HEIGHT)];
        height = MAX(descriptionY + ceilf(descriptionSize.height) + VERTICAL_PADDING * 2.0f + DESCRIPTION_Y_OFFSET + HEIGHT_DELTA,
                     COMMENT_CELL_MIN_HEIGHT);
        BOOL canExpand = height > COLLAPSED_COMMENT_CELL_MAX_HEIGHT;
        if(canExpand) {
            return canExpand;
        }
    }

    return NO;
}

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier {
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    
    if(self) {
        UIView * contentView = [super valueForKey:@"_contentCellView"];
        [self setSelectionStyle:UITableViewCellSelectionStyleNone];
        _contentBackgroundInsets = UIEdgeInsetsZero;
        _contentInsets = UIEdgeInsetsMake(VERTICAL_PADDING, CONTENT_INSET, 0.0f, CONTENT_INSET);

        _contentBackgroundView = [[UIView alloc] init];
        _contentBackgroundView.backgroundColor = CONTEN_BACKGROUND_COLOR;
        [contentView addSubview:_contentBackgroundView];
        
        _dateLabel = [self makeLabelWithTextColor:IQ_FONT_GRAY_COLOR
                                             font:[UIFont fontWithName:IQ_HELVETICA size:DEFAULT_FONT_SIZE]
                                    localaizedKey:nil];
        _dateLabel.textAlignment = NSTextAlignmentRight;
        [contentView addSubview:_dateLabel];
        
        _userNameLabel = [self makeLabelWithTextColor:IQ_FONT_WHITE_COLOR
                                                 font:[UIFont fontWithName:IQ_HELVETICA size:DEFAULT_FONT_SIZE]
                                        localaizedKey:nil];
        _userNameLabel.backgroundColor = [UIColor clearColor];
        _userNameLabel.textAlignment = NSTextAlignmentCenter;
        _userNameLabel.backgroundColor = IQ_GRAY_COLOR;
        _userNameLabel.layer.cornerRadius = 3;
        _userNameLabel.clipsToBounds = YES;
        [contentView addSubview:_userNameLabel];
        
        _onlineIndicator = [[IQOnlineIndicator alloc] init];
        [contentView addSubview:_onlineIndicator];
        
        _singleTapGesture = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(singleTapRecognized:)];
        _singleTapGesture.numberOfTapsRequired = 1;

        _descriptionTextView = [[IQTextView alloc] init];
        [_descriptionTextView setFont:DESCRIPTION_LABEL_FONT];
        [_descriptionTextView setTextColor:IQ_FONT_GRAY_DARK_COLOR];
        _descriptionTextView.textAlignment = NSTextAlignmentLeft;
        _descriptionTextView.backgroundColor = [UIColor clearColor];
        _descriptionTextView.editable = NO;
        _descriptionTextView.textContainerInset = UIEdgeInsetsZero;
        _descriptionTextView.scrollEnabled = NO;
        _descriptionTextView.dataDetectorTypes = UIDataDetectorTypeLink | UIDataDetectorTypePhoneNumber;
        _descriptionTextView.linkTextAttributes = @{
                                                    NSForegroundColorAttributeName: [UIColor colorWithHexInt:0x358bae],
                                                    NSUnderlineStyleAttributeName: @(NSUnderlineStyleSingle)
                                                    };
        
        [_descriptionTextView addGestureRecognizer:_singleTapGesture];
        [contentView addSubview:_descriptionTextView];
        
        UIColor * titleColor = IQ_BLUE_COLOR;
        UIColor * titleHighlightedColor = IQ_BAR_P2_COLOR;
        UIImage * bacgroundImage = [UIImage imageNamed:@"view_all_ico.png"];
        CGFloat expandFontSize = (IS_IPAD) ? 12 : 11.0f;
        _expandButton = [[UIButton alloc] init];
        [_expandButton setImage:bacgroundImage forState:UIControlStateNormal];
        [_expandButton.titleLabel setFont:[UIFont fontWithName:IQ_HELVETICA size:expandFontSize]];
        [_expandButton setTitleColor:titleColor forState:UIControlStateNormal];
        [_expandButton setTitleColor:titleHighlightedColor forState:UIControlStateHighlighted];
        [_expandButton setTitleEdgeInsets:UIEdgeInsetsMake(0.0f, 5.0f, 0.0f, 0.0f)];
        _expandButton.contentHorizontalAlignment = UIControlContentHorizontalAlignmentLeft;

        NSDictionary *underlineAttribute = @{
                                             NSFontAttributeName            : [UIFont fontWithName:IQ_HELVETICA size:expandFontSize],
                                             NSUnderlineStyleAttributeName  : @(NSUnderlineStyleSingle),
                                             NSForegroundColorAttributeName : titleColor
                                             };
        [_expandButton setAttributedTitle:[[NSAttributedString alloc] initWithString:NSLocalizedString(@"Show all", nil)
                                                                          attributes:underlineAttribute]
                                 forState:UIControlStateNormal];
        
        underlineAttribute = @{
                               NSFontAttributeName            : [UIFont fontWithName:IQ_HELVETICA size:expandFontSize],
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
    CGFloat labelsOffset = 5.0f;
    
    CGRect contentBackgroundBounds = UIEdgeInsetsInsetRect(bounds, _contentBackgroundInsets);
    _contentBackgroundView.frame = contentBackgroundBounds;
    
    CGSize topLabelSize = CGSizeMake(actualBounds.size.width / 2.0f,
                                     (IS_IPAD) ? 22 : 16.0f);
    if (([_userNameLabel.text length] > 0)) {
        CGSize userSize = [_userNameLabel.text sizeWithFont:_userNameLabel.font
                                          constrainedToSize:topLabelSize
                                              lineBreakMode:NSLineBreakByWordWrapping];
        
        _userNameLabel.frame = CGRectMake(actualBounds.origin.x + labelsOffset,
                                          actualBounds.origin.y,
                                          userSize.width + 5,
                                          topLabelSize.height);
    }
    
    _onlineIndicator.frame = CGRectMake(CGRectRight(_userNameLabel.frame) + ONLINE_INDICATOR_LEFT_OFFSET,
                                        _userNameLabel.frame.origin.y + (_userNameLabel.bounds.size.height - ONLINE_INDICATOR_SIZE) / 2.0f,
                                        ONLINE_INDICATOR_SIZE,
                                        ONLINE_INDICATOR_SIZE);
    
    _dateLabel.frame = CGRectMake(actualBounds.origin.x + actualBounds.size.width - topLabelSize.width,
                                  actualBounds.origin.y,
                                  topLabelSize.width,
                                  topLabelSize.height);
    
    CGFloat attachmentRectHeight = (hasAttachment) ? ATTACHMENTS_VIEW_HEIGHT + ATTACHMENT_VIEW_Y_OFFSET : 0.0f;
    CGFloat expandViewHeight = (hasExpandView) ? 15.0f + ATTACHMENT_VIEW_Y_OFFSET : 0.0f;
    CGFloat descriptionY = CGRectBottom(_userNameLabel.frame) + DESCRIPTION_Y_OFFSET;
    CGFloat descriptionHeight = (hasDescription) ? actualBounds.size.height - descriptionY - attachmentRectHeight - expandViewHeight : 0.0f;
    
    _descriptionTextView.frame = CGRectMake(actualBounds.origin.x + labelsOffset,
                                            descriptionY,
                                            actualBounds.size.width,
                                            (hasDescription) ? descriptionHeight : 0.0f);
    
    if(hasExpandView) {
        _expandButton.frame = CGRectMake(_descriptionTextView.frame.origin.x + 7.0f,
                                         CGRectBottom(_descriptionTextView.frame) + 5.0f,
                                         (IS_IPAD) ? 100.0f : 90.0f,
                                         15.0f);
    }
    
    if(hasAttachment) {
        CGFloat attachmentX = _descriptionTextView.frame.origin.x + 5.0f;
        CGFloat attachmentY = (hasAttachment && !hasDescription) ? _descriptionTextView.frame.origin.y + 2.0f : CGRectBottom(_descriptionTextView.frame) + 5.0f;
        
        if(hasExpandView) {
            attachmentY = CGRectBottom(_expandButton.frame) + ATTACHMENT_VIEW_Y_OFFSET;
        }
        
        [_attachmentsView setFrame:CGRectMake(attachmentX, attachmentY, _descriptionTextView.frame.size.width, ATTACHMENTS_VIEW_HEIGHT)];
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

- (void)setItem:(IQComment *)item {
    _item = item;
    
    _commentIsMine = ([_item.author.userId isEqualToNumber:[IQSession defaultSession].userId]);
    
    _dateLabel.text = [_item.createDate dateToDayTimeString];
    _userNameLabel.hidden = ([_item.author.displayName length] == 0);
    _userNameLabel.text = _item.author.displayName;
    _onlineIndicator.online = _item.author.online.boolValue;
        
    if (item.attachments.count > 0) {
        [_attachmentsView setItems:[_item.attachments allObjects] isMine:YES];
    }
    
    if (_commentIsMine) {
        NSTimeInterval distanceBetweenDates = [[NSDate date] timeIntervalSinceDate:_item.createDate];
        NSInteger minutesBetweenDates = roundf(distanceBetweenDates / 60.0f);

        if (minutesBetweenDates < 15) {
            NSMutableArray *rightUtilityButtons = [NSMutableArray array];
            [rightUtilityButtons sw_addUtilityButtonWithColor:IQ_BACKGROUND_P1_COLOR
                                                         icon:[UIImage imageNamed:@"delete_ico.png"]];
            
            [self setRightUtilityButtons:rightUtilityButtons WithButtonWidth:68.0f];
        }
    }
    
    self.commentHighlighted = [_item.unread boolValue];
    
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
    _contentBackgroundView.backgroundColor = (_commentHighlighted) ? CONTEN_BACKGROUND_COLOR_HIGHLIGHTED :
                                                                     CONTEN_BACKGROUND_COLOR;
    _contentBackgroundInsets = UIEdgeInsetsMake(0, (_commentHighlighted) ? NEW_FLAG_WIDTH : 0, 0, 0);
    self.backgroundColor = (_commentHighlighted) ? NEW_FLAG_COLOR : IQ_BACKGROUND_P1_COLOR;
}

- (void)prepareForReuse {
    [super prepareForReuse];
    _commentIsMine = NO;
    _expanded = NO;
    _expandable = NO;
    _contentBackgroundInsets = UIEdgeInsetsZero;
    _contentBackgroundView.backgroundColor = CONTEN_BACKGROUND_COLOR;
    self.backgroundColor = IQ_BACKGROUND_P1_COLOR;
    
    [self hideUtilityButtonsAnimated:NO];
    [self setRightUtilityButtons:nil];
    
    _descriptionTextView.delegate = nil;
    _descriptionTextView.selectable = NO;
    _descriptionTextView.text = nil;
    _descriptionTextView.selectable = YES;
    [_descriptionTextView setTextColor:IQ_FONT_GRAY_DARK_COLOR];

    [_attachmentsView setItems:nil isMine:YES];

    
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

- (void)setExpandButtonTitle:(NSString*)title {
    CGFloat expandFontSize = (IS_IPAD) ? 12 : 11.0f;
    UIColor * titleColor = IQ_BLUE_COLOR;
    UIColor * titleHighlightedColor = IQ_BACKGROUND_P1_COLOR;
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

@end
