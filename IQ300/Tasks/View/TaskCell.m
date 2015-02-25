//
//  TaskCell.m
//  IQ300
//
//  Created by Tayphoon on 19.02.15.
//  Copyright (c) 2015 Tayphoon. All rights reserved.
//

#import "TaskCell.h"
#import "IQTask.h"
#import "NSDate+IQFormater.h"
#import "IQUser.h"
#import "IQCommunity.h"

#define CONTENT_INSETS 10.0f
#define TASK_ID_HEIGHT 11.0f
#define TASK_ID_WIDTH 50.0f
#define TITLE_MAX_HEIGHT 36.0f
#define COMM_NAME_MAX_HEIGHT 27.0f
#define COMM_NAME_WIDTH 140.0f
#define DUE_DATE_HEIGHT 13.0f
#define VERTICAL_PADDING 5.0f

#define TITLE_FONT [UIFont fontWithName:IQ_HELVETICA size:15.0f]
#define COMM_NAME_FONT [UIFont fontWithName:IQ_HELVETICA size:11.0f]

@implementation TaskCell

+ (UIColor*)colorForTaskType:(NSString*)type {
    static NSDictionary * _typeColors = nil;
    static dispatch_once_t oncePredicate;
    dispatch_once(&oncePredicate, ^{
        _typeColors = @{
                        @"new"     : [UIColor colorWithHexInt:0x3084a8],
                        @"in_work" : [UIColor colorWithHexInt:0xf8931f],
                        @"refused" : [UIColor colorWithHexInt:0xfb0007]
                       };
    });
    
    if([_typeColors objectForKey:type]) {
        return [_typeColors objectForKey:type];
    }
    
    return [UIColor colorWithHexInt:0x9f9f9f];
}

+ (CGFloat)heightForItem:(IQTask *)item andCellWidth:(CGFloat)cellWidth {
    CGFloat height = CONTENT_INSETS * 2.0f;

    if([item.title length] > 0) {
        CGFloat titleWidth = cellWidth - CONTENT_INSETS * 2.0f - TASK_ID_WIDTH;
        CGSize titleSize = [item.title sizeWithFont:TITLE_FONT
                                  constrainedToSize:CGSizeMake(titleWidth, CGFLOAT_MAX)
                                      lineBreakMode:NSLineBreakByWordWrapping];
        
        height += MIN(MAX(titleSize.height, TITLE_MAX_HEIGHT / 2.0f),  TITLE_MAX_HEIGHT);
    }
    
    height += DUE_DATE_HEIGHT + VERTICAL_PADDING * 2.0f;
    
    if([item.community.title length] > 0) {
        
        CGSize commSize = [item.community.title sizeWithFont:COMM_NAME_FONT
               constrainedToSize:CGSizeMake(COMM_NAME_WIDTH, COMM_NAME_MAX_HEIGHT)
                   lineBreakMode:NSLineBreakByWordWrapping];
        
        height += MIN(MAX(commSize.height, COMM_NAME_MAX_HEIGHT / 2.0f),  CGFLOAT_MAX);
    }
    
    return height;
}

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier {
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    
    if(self) {
        UIView * contentView = self.contentView;
        _contentInsets = UIEdgeInsetsMakeWithInset(CONTENT_INSETS);
        
        _titleLabel = [self makeLabelWithTextColor:[UIColor blackColor]
                                                 font:TITLE_FONT
                                        localaizedKey:nil];
        [contentView addSubview:_titleLabel];
        
        _taskIDLabel = [self makeLabelWithTextColor:[UIColor colorWithHexInt:0x9f9f9f]
                                font:[UIFont fontWithName:IQ_HELVETICA size:11.0f]
                       localaizedKey:nil];
        _taskIDLabel.textAlignment = NSTextAlignmentRight;
        [contentView addSubview:_taskIDLabel];
        
        _fromLabel = [self makeLabelWithTextColor:[UIColor colorWithHexInt:0x9f9f9f]
                                             font:[UIFont fontWithName:IQ_HELVETICA size:11.0f]
                                    localaizedKey:nil];
        _fromLabel.numberOfLines = 1;
        [contentView addSubview:_fromLabel];
        
        _toLabel = [self makeLabelWithTextColor:[UIColor colorWithHexInt:0x9f9f9f]
                                           font:[UIFont fontWithName:IQ_HELVETICA size:11.0f]
                                  localaizedKey:nil];
        _toLabel.numberOfLines = 1;
        [contentView addSubview:_toLabel];
        
        _dueIconImageVIew = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"bell_ico.png"]];
        [contentView addSubview:_dueIconImageVIew];
        
        _dueDateLabel = [self makeLabelWithTextColor:[UIColor colorWithHexInt:0x272727]
                                               font:[UIFont fontWithName:IQ_HELVETICA size:11.0f]
                                      localaizedKey:nil];
        _dueDateLabel.textAlignment = NSTextAlignmentRight;
        [contentView addSubview:_dueDateLabel];
        
        _communityImageVIew = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"community_ico.png"]];
        [contentView addSubview:_communityImageVIew];
        
        _communityNameLabel = [self makeLabelWithTextColor:[UIColor colorWithHexInt:0x9f9f9f]
                                                         font:COMM_NAME_FONT
                                                localaizedKey:nil];
        [contentView addSubview:_communityNameLabel];
        
        _messagesImageVIew = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"message_blue_buble.png"]];
        [contentView addSubview:_messagesImageVIew];

        _commentsCountLabel = [self makeLabelWithTextColor:[UIColor colorWithHexInt:0x272727]
                                                font:[UIFont fontWithName:IQ_HELVETICA size:11.0f]
                                       localaizedKey:nil];
        [contentView addSubview:_commentsCountLabel];
        
        _statusLabel = [self makeLabelWithTextColor:[UIColor colorWithHexInt:0x9f9f9f]
                                               font:[UIFont fontWithName:IQ_HELVETICA size:11.0f]
                                             localaizedKey:nil];
        _statusLabel.textAlignment = NSTextAlignmentRight;
        [contentView addSubview:_statusLabel];
    }
    
    return self;
}

- (void)layoutSubviews {
    [super layoutSubviews];
    
    CGRect bounds = self.contentView.bounds;
    CGRect actualBounds = UIEdgeInsetsInsetRect(bounds, _contentInsets);
    
    CGSize taskIDSize = CGSizeMake(TASK_ID_WIDTH, TASK_ID_HEIGHT);
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
    
    CGSize dueIconImageSize = [_dueIconImageVIew image].size;
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
    
    _dueIconImageVIew.frame = CGRectMake(_dueDateLabel.frame.origin.x - dueIconImageSize.width - 4.0f,
                                         _dueDateLabel.frame.origin.y + 2.0f,
                                         dueIconImageSize.width,
                                         dueIconImageSize.height);
    
    CGRect usersLabelFrame = CGRectMake(actualBounds.origin.x,
                                         _dueDateLabel.frame.origin.y,
                                         _dueIconImageVIew.frame.origin.x - actualBounds.origin.x,
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
    
    CGSize communityImageSize = [_communityImageVIew image].size;
    _communityImageVIew.frame = CGRectMake(actualBounds.origin.x,
                                           CGRectBottom(_fromLabel.frame) + VERTICAL_PADDING,
                                           communityImageSize.width,
                                           communityImageSize.height);
    
    constrainedSize = CGSizeMake(COMM_NAME_WIDTH, COMM_NAME_MAX_HEIGHT);
    CGSize communityNameSize = [_communityNameLabel.text sizeWithFont:_communityNameLabel.font
                                                    constrainedToSize:constrainedSize
                                                        lineBreakMode:NSLineBreakByWordWrapping];
    
    _communityNameLabel.frame = CGRectMake(CGRectRight(_communityImageVIew.frame) + 5.0f,
                                              _communityImageVIew.frame.origin.y + 1.8f,
                                              140,
                                              communityNameSize.height);
    
    CGSize messagesImageSize = [_messagesImageVIew image].size;
    _messagesImageVIew.frame = CGRectMake(CGRectRight(_communityNameLabel.frame) + 5.0f,
                                          _communityImageVIew.frame.origin.y + 2.0f,
                                          messagesImageSize.width,
                                          messagesImageSize.height);
    
    _commentsCountLabel.frame = CGRectMake(CGRectRight(_messagesImageVIew.frame) + 5.0f,
                                           _messagesImageVIew.frame.origin.y,
                                           20.0f,
                                           messagesImageSize.height);
    
    CGFloat statusLabelX = CGRectRight(_commentsCountLabel.frame) + 5.0f;
    _statusLabel.frame = CGRectMake(statusLabelX,
                                    _commentsCountLabel.frame.origin.y,
                                    (actualBounds.origin.x + actualBounds.size.width) - statusLabelX,
                                    _commentsCountLabel.frame.size.height);
}

- (void)setItem:(IQTask *)item {
    _item = item;
    
    _taskIDLabel.text = [NSString stringWithFormat:@"#%@", _item.taskId];
    _titleLabel.text = _item.title;
    _dueDateLabel.text = [_item.endDate dateToDayString];
    _fromLabel.text = _item.customer.displayName;
    _toLabel.text = [NSString stringWithFormat:@"> %@", _item.executor.displayName];
    _communityNameLabel.text = _item.community.title;
    
    BOOL showCommentsCount = ([_item.commentsCount integerValue] > 0);
    
    _commentsCountLabel.hidden = !showCommentsCount;
    _messagesImageVIew.hidden = !showCommentsCount;
    _commentsCountLabel.text = [NSString stringWithFormat:@"%@", _item.commentsCount];
    
    _statusLabel.textColor = [TaskCell colorForTaskType:_item.status];
    _statusLabel.text = NSLocalizedString(_item.status, nil);
    [self setNeedsLayout];
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
