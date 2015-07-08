//
//  ConversationCell.m
//  IQ300
//
//  Created by Tayphoon on 02.12.14.
//  Copyright (c) 2014 Tayphoon. All rights reserved.
//
#import <QuartzCore/QuartzCore.h>
#import <SDWebImage/UIImageView+WebCache.h>

#import "ConversationCell.h"
#import "NSDate+IQFormater.h"
#import "IQBadgeView.h"
#import "IQConversation.h"
#import "IQSession.h"

#define DEFAULT_AVATAR_IMAGE @"default_avatar.png"
#define USER_ICON_SEZE 20
#define HEIGHT_DELTA 1.0f
#define VERTICAL_PADDING 10
#define DESCRIPTION_Y_OFFSET 3.0f
#define CELL_HEADER_MIN_HEIGHT USER_ICON_SEZE
#define CONTEN_BACKGROUND_COLOR [UIColor colorWithHexInt:0xe9faff]
#define CONTEN_BACKGROUND_COLOR_R [UIColor whiteColor]

#ifdef IPAD
#define LABELS_FONT [UIFont fontWithName:IQ_HELVETICA size:14]
#define ATTACHMENT_VIEW_HEIGHT 15.0f
#else
#define LABELS_FONT [UIFont fontWithName:IQ_HELVETICA size:13]
#define ATTACHMENT_VIEW_HEIGHT 15.0f
#endif

@interface ConversationCell() {
    BOOL _lastCommentIsMine;
}

@end

@implementation ConversationCell

+ (CGFloat)heightForItem:(IQConversation *)item andCellWidth:(CGFloat)cellWidth {
    CGFloat descriptionY = CELL_HEADER_MIN_HEIGHT;
    CGFloat descriptionWidth = cellWidth;
    CGFloat height = CONVERSATION_CELL_MIN_HEIGHT;

    if([item.lastComment.body length] > 0) {
        CGSize descriptionSize = [item.lastComment.body sizeWithFont:LABELS_FONT
                                                   constrainedToSize:CGSizeMake(descriptionWidth, CONVERSATION_CELL_MAX_HEIGHT)
                                                       lineBreakMode:NSLineBreakByWordWrapping];
        height = MAX(descriptionY + descriptionSize.height + VERTICAL_PADDING * 2.0f + DESCRIPTION_Y_OFFSET + HEIGHT_DELTA,
                     CONVERSATION_CELL_MIN_HEIGHT);
    }

    BOOL hasDescription = ([item.lastComment.body length] > 0);
    BOOL hasAttachment = ([item.lastComment.attachments count] > 0);
    if(hasAttachment && hasDescription) {
        height += ATTACHMENT_VIEW_HEIGHT;
    }

    return height;
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
        
        _userImageView = [[UIImageView alloc] init];
        _userImageView.layer.cornerRadius = USER_ICON_SEZE / 2.0f;
        [_userImageView setImage:[UIImage imageNamed:DEFAULT_AVATAR_IMAGE]];
        [_userImageView setClipsToBounds:YES];
        [contentView addSubview:_userImageView];
        
        _dateLabel = [self makeLabelWithTextColor:[UIColor colorWithHexInt:0xb3b3b3]
                                             font:LABELS_FONT
                                    localaizedKey:nil];
        _dateLabel.textAlignment = NSTextAlignmentRight;
        [contentView addSubview:_dateLabel];
        
        _userNameLabel = [self makeLabelWithTextColor:[UIColor colorWithHexInt:0x358bae]
                                                 font:LABELS_FONT
                                        localaizedKey:nil];
        _userNameLabel.backgroundColor = [UIColor clearColor];
        _userNameLabel.textAlignment = NSTextAlignmentLeft;
        [contentView addSubview:_userNameLabel];
                
        _descriptionLabel = [self makeLabelWithTextColor:[UIColor colorWithHexInt:0x8b8b8b]
                                                    font:LABELS_FONT
                                           localaizedKey:nil];
        [contentView addSubview:_descriptionLabel];
        
        IQBadgeStyle * style = [IQBadgeStyle defaultStyle];
        style.badgeTextColor = [UIColor whiteColor];
        style.badgeInsetColor = [UIColor colorWithHexInt:0x338cae];
     
        _badgeView = [IQBadgeView customBadgeWithString:nil withStyle:style];
        _badgeView.badgeMinSize = (IS_IPAD) ? 26 : 17;
        _badgeView.badgeTextFont = [UIFont fontWithName:IQ_HELVETICA size:(IS_IPAD) ? 13 : 10];
        [_badgeView setHidden:YES];
        [contentView addSubview:_badgeView];
        
        _attachButton = [[UIButton alloc] init];
        [_attachButton setImage:[UIImage imageNamed:@"attach_ico.png"] forState:UIControlStateNormal];
        [_attachButton setImage:[UIImage imageNamed:@"attach_ico.png"] forState:UIControlStateDisabled];
        [_attachButton.titleLabel setFont:[UIFont fontWithName:IQ_HELVETICA
                                                          size:(IS_IPAD) ? 13 : 11]];
        [_attachButton setTitleColor:[UIColor colorWithHexInt:0x358bae] forState:UIControlStateNormal];
        [_attachButton setTitleColor:[UIColor colorWithHexInt:0x358bae] forState:UIControlStateDisabled];
        [_attachButton setTitleEdgeInsets:UIEdgeInsetsMake(0.0f, 5.0f, 0.0f, 0.0f)];
        _attachButton.contentHorizontalAlignment = UIControlContentHorizontalAlignmentLeft;
        [_attachButton setHidden:YES];
        [_attachButton setEnabled:NO];
        [contentView addSubview:_attachButton];
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

    CGFloat nameOffset = 6;
    _userImageView.frame = CGRectMake(actualBounds.origin.x + labelsOffset,
                                      actualBounds.origin.y,
                                      USER_ICON_SEZE,
                                      USER_ICON_SEZE);

    CGFloat dateMaxWidth = 160;
    CGSize dateLabelSize = [_dateLabel.text sizeWithFont:_dateLabel.font
                                       constrainedToSize:CGSizeMake(dateMaxWidth, CELL_HEADER_MIN_HEIGHT)
                                           lineBreakMode:NSLineBreakByWordWrapping];
    CGFloat dateLabelWidth = MIN(dateLabelSize.width + 6.0f, dateMaxWidth);
    CGFloat dateLabelX = actualBounds.origin.x + actualBounds.size.width - dateLabelWidth;
    _dateLabel.frame = CGRectMake(dateLabelX,
                                  actualBounds.origin.y,
                                  dateLabelWidth,
                                  CELL_HEADER_MIN_HEIGHT);
    
    CGFloat userNameX = CGRectRight(_userImageView.frame) + nameOffset;
    _userNameLabel.frame = CGRectMake(userNameX,
                                      actualBounds.origin.y,
                                      _dateLabel.frame.origin.x - userNameX - 4.0f,
                                      CELL_HEADER_MIN_HEIGHT);
    
    BOOL hasDescription = ([_item.lastComment.body length] > 0);
    BOOL hasAttachment = ([_item.lastComment.attachments count] > 0);
    
    CGFloat descriptionInset = (hasAttachment) ? ATTACHMENT_VIEW_HEIGHT : 0.0f;
    CGFloat descriptionY = CGRectBottom(_userNameLabel.frame) + DESCRIPTION_Y_OFFSET;
    CGFloat descriptionHeight = (hasDescription) ? actualBounds.size.height - descriptionY - descriptionInset : 0.0f;
    
    if(hasAttachment && !hasDescription) {
        descriptionHeight = 16.5f;
    }
    
    _descriptionLabel.frame = CGRectMake(actualBounds.origin.x + labelsOffset,
                                         descriptionY,
                                         (hasDescription) ? actualBounds.size.width - 40.0f :  (_lastCommentIsMine) ? 15.0f : 0.0f,
                                         descriptionHeight);
    if(hasAttachment) {
        CGFloat attachmentX = (hasAttachment && !hasDescription) ? CGRectRight(_descriptionLabel.frame) : _descriptionLabel.frame.origin.x;
        CGSize constrainedSize = CGSizeMake(actualBounds.size.width, 15.0f);
        CGSize attachmentSize = [_attachButton sizeThatFits:constrainedSize];
        
        _attachButton.frame = CGRectMake(attachmentX,
                                         (hasAttachment && !hasDescription) ? _descriptionLabel.frame.origin.y + 2.0f : CGRectBottom(_descriptionLabel.frame) + 5.0f,
                                         MIN(attachmentSize.width + 5.0f, actualBounds.size.width - attachmentX),
                                         attachmentSize.height);
    }
    
    _badgeView.frame = CGRectMake(actualBounds.origin.x + actualBounds.size.width - _badgeView.frame.size.width,
                                  CGRectBottom(_dateLabel.frame),
                                  _badgeView.frame.size.width,
                                  _badgeView.frame.size.height);
}

- (void)setItem:(IQConversation *)item {
    _item = item;
    
    BOOL hasUnreadComments = ([_item.unreadCommentsCount integerValue] > 0);
    _lastCommentIsMine = ([_item.lastComment.author.userId isEqualToNumber:[IQSession defaultSession].userId]);
    _contentBackgroundInsets = (hasUnreadComments) ? UIEdgeInsetsMake(0, 4, 0, 0) : UIEdgeInsetsZero;
    _contentBackgroundView.backgroundColor = (hasUnreadComments) ? CONTEN_BACKGROUND_COLOR :
                                                                   CONTEN_BACKGROUND_COLOR_R;
    NSPredicate * companionsPredicate = [NSPredicate predicateWithFormat:@"userId != %@", [IQSession defaultSession].userId];
    NSArray * companions = [[_item.discussion.users filteredSetUsingPredicate:companionsPredicate] allObjects];
    IQUser * companion = [companions lastObject];
    
    _dateLabel.text = [_item.lastComment.createDate dateToDayTimeString];
    _userNameLabel.hidden = ([companion.displayName length] == 0);
    _userNameLabel.text = companion.displayName;
    _companion = companion;
    
    UIImage * defaulImage = ([companions count] > 1) ? [UIImage imageNamed:@"conference_ioc.png"] :
                                                       [UIImage imageNamed:@"user_icon.png"];
    if([companion.thumbUrl length] > 0) {
        [_userImageView sd_setImageWithURL:[NSURL URLWithString:companion.thumbUrl]];
    }
    else {
        _userImageView.image = defaulImage;
    }
    
    NSString * body = ([_item.lastComment.body length] > 0) ? _item.lastComment.body : @"";
    body = (_lastCommentIsMine) ? [NSString stringWithFormat:@"%@: %@", NSLocalizedString(@"I", nil), body] : body;
    _descriptionLabel.text = body;
    NSString * badgeValue = BadgTextFromInteger([_item.unreadCommentsCount integerValue]);
    [self setBadgeText:(hasUnreadComments) ?  badgeValue : nil];
    
    BOOL hasAttachment = ([_item.lastComment.attachments count] > 0);
    [_attachButton setHidden:(!hasAttachment)];
    
    if(hasAttachment) {
        IQAttachment * attachment = [[_item.lastComment.attachments allObjects] lastObject];
        [_attachButton setTitle:attachment.displayName forState:UIControlStateNormal];
    }

    [self setNeedsLayout];
}

- (void)prepareForReuse {
    [super prepareForReuse];
    
    _contentBackgroundInsets = UIEdgeInsetsZero;
    _contentBackgroundView.backgroundColor = CONTEN_BACKGROUND_COLOR_R;
    _companion = nil;
    _lastCommentIsMine = NO;
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

- (void)setBadgeText:(NSString *)badgeText {
    if([badgeText length] > 0) {
        [_badgeView setHidden:NO];
        [_badgeView setBadgeValue:badgeText];
    }
    else {
        [_badgeView setHidden:YES];
    }
}

@end
