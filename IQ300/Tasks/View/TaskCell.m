//
//  TaskCell.m
//  IQ300
//
//  Created by Tayphoon on 19.02.15.
//  Copyright (c) 2015 Tayphoon. All rights reserved.
//
#import <SDWebImage/UIImageView+WebCache.h>

#import "TaskCell.h"
#import "IQTask.h"
#import "NSDate+IQFormater.h"
#import "IQUser.h"
#import "IQCommunity.h"
#import "TaskHelper.h"

#define CONTENT_INSETS 10.0f
#define TASK_ID_WIDTH 50.0f
#define TITLE_MAX_HEIGHT 36.0f
#define COMM_NAME_WIDTH 140.0f
#define VERTICAL_PADDING 5.0f

#define COMMUNITY_ICO_SIZE 17.0f

#define STATUS_FLAG_WIDTH 4.0f
#define NEW_FLAG_COLOR [UIColor colorWithHexInt:0x005275]
#define OVERDUE_FLAG_COLOR [UIColor colorWithHexInt:0xe74545]
#define CONTEN_BACKGROUND_COLOR_NEW [UIColor colorWithHexInt:0xe9faff]
#define CONTEN_BACKGROUND_COLOR [UIColor whiteColor]

#ifdef IPAD

#define TITLE_FONT [UIFont fontWithName:IQ_HELVETICA size:17.0f]
#define LABELS_FONT [UIFont fontWithName:IQ_HELVETICA size:12.0f]
#define LABELS_HEIGHT 15.0f
#define COMM_NAME_MAX_HEIGHT 32.0f
#else
#define TITLE_FONT [UIFont fontWithName:IQ_HELVETICA size:15.0f]
#define LABELS_FONT [UIFont fontWithName:IQ_HELVETICA size:11.0f]
#define LABELS_HEIGHT 13.0f
#define COMM_NAME_MAX_HEIGHT 27.0f
#endif

@implementation TaskCell

+ (CGFloat)heightForItem:(IQTask *)item andCellWidth:(CGFloat)cellWidth {
    CGFloat height = CONTENT_INSETS * 2.0f;
    CGFloat width = cellWidth - CONTENT_INSETS * 2.0f;

    if([item.title length] > 0) {
        CGFloat titleWidth = width - TASK_ID_WIDTH;
        CGSize titleSize = [item.title sizeWithFont:TITLE_FONT
                                  constrainedToSize:CGSizeMake(titleWidth, CGFLOAT_MAX)
                                      lineBreakMode:NSLineBreakByWordWrapping];
        
        height += MIN(MAX(titleSize.height, TITLE_MAX_HEIGHT / 2.0f),  TITLE_MAX_HEIGHT);
    }
    
    height += LABELS_HEIGHT + VERTICAL_PADDING * 2.0f;
    
    if([item.community.title length] > 0) {
        CGFloat commWidth = width / 2.0f - 30.0f;
        CGSize commSize = [item.community.title sizeWithFont:LABELS_FONT
               constrainedToSize:CGSizeMake(commWidth, COMM_NAME_MAX_HEIGHT)
                   lineBreakMode:NSLineBreakByWordWrapping];
        
        height += MIN(MAX(commSize.height, COMM_NAME_MAX_HEIGHT / 2.0f),  CGFLOAT_MAX);
    }
    
    return height;
}

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier {
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    
    if(self) {
        self.selectionStyle = UITableViewCellSelectionStyleNone;
        
        UIView * contentView = self.contentView;
        _contentInsets = UIEdgeInsetsMakeWithInset(CONTENT_INSETS);
        _contentBackgroundInsets = UIEdgeInsetsZero;
        
        [self setBackgroundColor:NEW_FLAG_COLOR];
        
        _contentBackgroundView = [[UIView alloc] init];
        _contentBackgroundView.backgroundColor = CONTEN_BACKGROUND_COLOR;
        [contentView addSubview:_contentBackgroundView];

        _titleLabel = [self makeLabelWithTextColor:[UIColor blackColor]
                                                 font:TITLE_FONT
                                        localaizedKey:nil];
        [contentView addSubview:_titleLabel];
        
        _taskIDLabel = [self makeLabelWithTextColor:[UIColor colorWithHexInt:0x9f9f9f]
                                font:LABELS_FONT
                       localaizedKey:nil];
        _taskIDLabel.textAlignment = NSTextAlignmentRight;
        [contentView addSubview:_taskIDLabel];
        
        _fromLabel = [self makeLabelWithTextColor:[UIColor colorWithHexInt:0x9f9f9f]
                                             font:LABELS_FONT
                                    localaizedKey:nil];
        _fromLabel.numberOfLines = 1;
        [contentView addSubview:_fromLabel];
        
        _toLabel = [self makeLabelWithTextColor:[UIColor colorWithHexInt:0x9f9f9f]
                                           font:LABELS_FONT
                                  localaizedKey:nil];
        _toLabel.numberOfLines = 1;
        [contentView addSubview:_toLabel];
        
        _dueIconImageView = [[UIImageView alloc] init];
        [contentView addSubview:_dueIconImageView];
        
        _dueDateLabel = [self makeLabelWithTextColor:[UIColor colorWithHexInt:0x272727]
                                               font:LABELS_FONT
                                      localaizedKey:nil];
        _dueDateLabel.textAlignment = NSTextAlignmentRight;
        [contentView addSubview:_dueDateLabel];
        
        _communityImageView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"community_ico.png"]];
        _communityImageView.layer.cornerRadius = COMMUNITY_ICO_SIZE / 2.0f;
        _communityImageView.clipsToBounds = YES;
        [contentView addSubview:_communityImageView];
        
        _communityNameLabel = [self makeLabelWithTextColor:[UIColor colorWithHexInt:0x9f9f9f]
                                                         font:LABELS_FONT
                                                localaizedKey:nil];
        [contentView addSubview:_communityNameLabel];
        
        _messagesImageView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"message_blue_buble.png"]];
        [contentView addSubview:_messagesImageView];

        _commentsCountLabel = [self makeLabelWithTextColor:[UIColor colorWithHexInt:0x272727]
                                                font:LABELS_FONT
                                       localaizedKey:nil];
        [contentView addSubview:_commentsCountLabel];
        
        _statusLabel = [self makeLabelWithTextColor:[UIColor colorWithHexInt:0x9f9f9f]
                                               font:LABELS_FONT
                                             localaizedKey:nil];
        _statusLabel.textAlignment = NSTextAlignmentRight;
        [contentView addSubview:_statusLabel];
        
        _highlightTasks = YES;
    }
    
    return self;
}

- (void)layoutSubviews {
    [super layoutSubviews];
    
    CGRect bounds = self.contentView.bounds;
    CGRect actualBounds = UIEdgeInsetsInsetRect(bounds, _contentInsets);
    
    CGRect contentBackgroundBounds = UIEdgeInsetsInsetRect(bounds, _contentBackgroundInsets);
    _contentBackgroundView.frame = contentBackgroundBounds;

    CGSize taskIDSize = CGSizeMake(TASK_ID_WIDTH, LABELS_HEIGHT);
    _taskIDLabel.frame = CGRectMake(actualBounds.origin.x + actualBounds.size.width - taskIDSize.width,
                                    actualBounds.origin.y,
                                    taskIDSize.width,
                                    taskIDSize.height);
    
    CGSize constrainedSize = CGSizeMake(_taskIDLabel.frame.origin.x - actualBounds.origin.x,
                                        TITLE_MAX_HEIGHT);
    CGSize titleSize = [_titleLabel.text sizeWithFont:_titleLabel.font
                                    constrainedToSize:constrainedSize
                                        lineBreakMode:NSLineBreakByWordWrapping];
    
    _titleLabel.frame = CGRectMake(actualBounds.origin.x,
                                   actualBounds.origin.y - 1.8f,
                                   constrainedSize.width,
                                   titleSize.height);
    
    CGSize dueIconImageSize = [_dueIconImageView image].size;
    CGFloat dateHeight = dueIconImageSize.height + 2;
    CGFloat dateMaxWidth = 150;
    CGSize dateLabelSize = [_dueDateLabel.text sizeWithFont:_dueDateLabel.font
                                          constrainedToSize:CGSizeMake(dateMaxWidth, dateHeight)
                                              lineBreakMode:_dueDateLabel.lineBreakMode];
    CGFloat dateLabelWidth = MIN(dateLabelSize.width, dateMaxWidth);
    CGFloat dateLabelX = actualBounds.origin.x + actualBounds.size.width - dateLabelWidth;
    _dueDateLabel.frame = CGRectMake(dateLabelX,
                                     CGRectBottom(_titleLabel.frame) + VERTICAL_PADDING,
                                     dateLabelWidth,
                                     dateHeight);
    
    _dueIconImageView.frame = CGRectMake(_dueDateLabel.frame.origin.x - dueIconImageSize.width - 4.0f,
                                         _dueDateLabel.frame.origin.y + 2.0f,
                                         dueIconImageSize.width,
                                         dueIconImageSize.height);
    
    CGRect usersLabelFrame = CGRectMake(actualBounds.origin.x,
                                         _dueDateLabel.frame.origin.y,
                                         _dueIconImageView.frame.origin.x - actualBounds.origin.x,
                                         dateHeight);
    
    CGFloat userMaxWidth = usersLabelFrame.size.width / 2.0f;
    CGSize userLabelSize = [_fromLabel.text sizeWithFont:_fromLabel.font
                                          constrainedToSize:CGSizeMake(userMaxWidth, usersLabelFrame.size.height)
                                              lineBreakMode:_fromLabel.lineBreakMode];
    BOOL needOffset = (userLabelSize.width <= userMaxWidth - 5.0f);
    CGFloat userLabelWidth = MIN(userLabelSize.width, userMaxWidth);
    
    _fromLabel.frame = CGRectMake(usersLabelFrame.origin.x,
                                  usersLabelFrame.origin.y,
                                  userLabelWidth,
                                  usersLabelFrame.size.height);
    
    _toLabel.frame = CGRectMake(CGRectRight(_fromLabel.frame) + ((needOffset) ? 5.0f : 0.0f),
                                usersLabelFrame.origin.y,
                                usersLabelFrame.size.width / 2.0f,
                                usersLabelFrame.size.height);
    
    _communityImageView.frame = CGRectMake(actualBounds.origin.x,
                                           CGRectBottom(_fromLabel.frame) + VERTICAL_PADDING,
                                           COMMUNITY_ICO_SIZE,
                                           COMMUNITY_ICO_SIZE);
    
    CGSize messagesImageSize = [_messagesImageView image].size;
    _messagesImageView.frame = CGRectMake((actualBounds.origin.x + actualBounds.size.width) / 2.0f,
                                          _communityImageView.frame.origin.y + 2.0f,
                                          messagesImageSize.width,
                                          messagesImageSize.height);
    
    _commentsCountLabel.frame = CGRectMake(CGRectRight(_messagesImageView.frame) + 5.0f,
                                           _messagesImageView.frame.origin.y,
                                           20.0f,
                                           messagesImageSize.height);

    CGFloat communityWidth = _messagesImageView.frame.origin.x - _communityImageView.frame.origin.x - actualBounds.origin.x - 10.0f;
    constrainedSize = CGSizeMake(communityWidth, COMM_NAME_MAX_HEIGHT);
    CGSize communityNameSize = [_communityNameLabel.text sizeWithFont:_communityNameLabel.font
                                                    constrainedToSize:constrainedSize
                                                        lineBreakMode:NSLineBreakByWordWrapping];
    
    _communityNameLabel.frame = CGRectMake(CGRectRight(_communityImageView.frame) + 5.0f,
                                           _communityImageView.frame.origin.y + 1.8f,
                                           constrainedSize.width,
                                           communityNameSize.height);
    
    CGFloat statusLabelX = CGRectRight(_commentsCountLabel.frame) + 5.0f;
    CGFloat labelWidth = MIN(100.0f, (actualBounds.origin.x + actualBounds.size.width) - statusLabelX);
    _statusLabel.frame = CGRectMake((actualBounds.origin.x + actualBounds.size.width) - labelWidth,
                                    _commentsCountLabel.frame.origin.y,
                                    labelWidth,
                                   LABELS_HEIGHT);
}

- (void)setItem:(IQTask *)item {
    _item = item;
    
    _taskIDLabel.text = [NSString stringWithFormat:@"#%@", _item.taskId];
    _titleLabel.text = _item.title;
    _dueDateLabel.text = [_item.endDate dateToDayString];
    _fromLabel.text = _item.customer.displayName;
    _toLabel.text = [NSString stringWithFormat:@"> %@", _item.executor.displayName];
    
    _communityNameLabel.text = _item.community.title;
    
    if([_item.community.thumbUrl length] > 0) {
        [_communityImageView sd_setImageWithURL:[NSURL URLWithString:_item.community.thumbUrl]
                               placeholderImage:[UIImage imageNamed:@"community_ico.png"]];
    }
    else {
        _communityImageView.image = [UIImage imageNamed:@"community_ico.png"];
    }
    
    BOOL showCommentsCount = ([_item.commentsCount integerValue] > 0);
    
    _commentsCountLabel.hidden = !showCommentsCount;
    _messagesImageView.hidden = !showCommentsCount;
    _commentsCountLabel.text = [NSString stringWithFormat:@"%@", _item.commentsCount];
    
    NSString * status = ([[_item.type lowercaseString] isEqualToString:@"templatetask"]) ? @"template" : _item.status;
    _statusLabel.textColor = [TaskHelper colorForTaskType:status];
    _statusLabel.text = NSLocalizedString(status, nil);
    [self updateUIForState];
    
    [self setNeedsLayout];
}

- (void)updateUIForState {
    BOOL isStatusNew = ([_item.status isEqualToString:@"new"]);
    BOOL isOutOfDate = ([_item.endDate compare:[NSDate date]] == NSOrderedAscending);
    if (_highlightTasks && isOutOfDate) {
        _dueIconImageView.image = [UIImage imageNamed:@"bell_red_ico.png"];
        _dueDateLabel.textColor = [UIColor colorWithHexInt:0xca301e];
        _contentBackgroundInsets = UIEdgeInsetsMake(0, STATUS_FLAG_WIDTH, 0, 0);
        [self setBackgroundColor:OVERDUE_FLAG_COLOR];
    }
    else {
        _dueIconImageView.image = [UIImage imageNamed:@"bell_ico.png"];
        _dueDateLabel.textColor = [UIColor colorWithHexInt:0x272727];
        _contentBackgroundInsets = (isStatusNew && _highlightTasks) ? UIEdgeInsetsMake(0, STATUS_FLAG_WIDTH, 0, 0) : UIEdgeInsetsZero;
        self.backgroundColor = (isStatusNew && _highlightTasks) ? NEW_FLAG_COLOR : CONTEN_BACKGROUND_COLOR;
    }
    
    _contentBackgroundView.backgroundColor = (isStatusNew && _highlightTasks) ? CONTEN_BACKGROUND_COLOR_NEW : CONTEN_BACKGROUND_COLOR;
}

- (void)prepareForReuse {
    [super prepareForReuse];
    
    _highlightTasks = YES;
    _dueIconImageView.image = [UIImage imageNamed:@"bell_ico.png"];
    _dueDateLabel.textColor = [UIColor colorWithHexInt:0x272727];
    _contentBackgroundInsets = UIEdgeInsetsZero;
    _contentBackgroundView.backgroundColor = CONTEN_BACKGROUND_COLOR;
    self.backgroundColor = CONTEN_BACKGROUND_COLOR;
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
