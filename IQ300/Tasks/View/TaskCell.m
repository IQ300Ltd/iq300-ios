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

@implementation TaskCell

+ (CGFloat)heightForItem:(IQTask *)item andCellWidth:(CGFloat)cellWidth {
    
    return 0;
}

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier {
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    
    if(self) {
        UIView * contentView = self.contentView;
        _contentInsets = UIEdgeInsetsMakeWithInset(10.0f);
        
        _titleTextView = [[UITextView alloc] init];
        [_titleTextView setFont:[UIFont fontWithName:IQ_HELVETICA size:15.0f]];
        [_titleTextView setTextColor:[UIColor blackColor]];
        _titleTextView.textAlignment = NSTextAlignmentLeft;
        _titleTextView.backgroundColor = [UIColor clearColor];
        _titleTextView.editable = NO;
        _titleTextView.textContainerInset = UIEdgeInsetsZero;
        _titleTextView.textContainer.lineFragmentPadding = 0;
        _titleTextView.scrollEnabled = NO;
        [contentView addSubview:_titleTextView];
        
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
        
        _communityNameTextView = [[UITextView alloc] init];
        [_communityNameTextView setFont:[UIFont fontWithName:IQ_HELVETICA size:11.0f]];
        [_communityNameTextView setTextColor:[UIColor colorWithHexInt:0x9f9f9f]];
        _communityNameTextView.textAlignment = NSTextAlignmentLeft;
        _communityNameTextView.backgroundColor = [UIColor clearColor];
        _communityNameTextView.editable = NO;
        _communityNameTextView.textContainerInset = UIEdgeInsetsZero;
        _communityNameTextView.textContainer.lineFragmentPadding = 0;
        _communityNameTextView.scrollEnabled = NO;
        [contentView addSubview:_communityNameTextView];
        
        _messagesImageVIew = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"message_blue_buble.png"]];
        [contentView addSubview:_messagesImageVIew];

        _messagesCountLabel = [self makeLabelWithTextColor:[UIColor colorWithHexInt:0x272727]
                                                font:[UIFont fontWithName:IQ_HELVETICA size:11.0f]
                                       localaizedKey:nil];
        [contentView addSubview:_messagesCountLabel];
        
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
    
    CGSize taskIDSize = CGSizeMake(50.0f, 11.0f);
    _taskIDLabel.frame = CGRectMake(actualBounds.origin.x + actualBounds.size.width - taskIDSize.width,
                                    actualBounds.origin.y,
                                    taskIDSize.width,
                                    taskIDSize.height);
    
    _titleTextView.frame = CGRectMake(actualBounds.origin.x,
                                      actualBounds.origin.y - 1.8f,
                                      _taskIDLabel.frame.origin.x - actualBounds.origin.x,
                                      36.0f);
    
    CGSize dueIconImageSize = [_dueIconImageVIew image].size;
    CGFloat dateHeight = dueIconImageSize.height;
    CGFloat dateMaxWidth = 150;
    CGSize dateLabelSize = [_dueDateLabel.text sizeWithFont:_dueDateLabel.font
                                          constrainedToSize:CGSizeMake(dateMaxWidth, dateHeight)
                                              lineBreakMode:_dueDateLabel.lineBreakMode];
    CGFloat dateLabelWidth = MIN(dateLabelSize.width, dateMaxWidth);
    CGFloat dateLabelX = actualBounds.origin.x + actualBounds.size.width - dateLabelWidth;
    _dueDateLabel.frame = CGRectMake(dateLabelX,
                                     CGRectBottom(_titleTextView.frame) + 5.0f,
                                     dateLabelWidth,
                                     dateHeight);
    
    _dueIconImageVIew.frame = CGRectMake(_dueDateLabel.frame.origin.x - dueIconImageSize.width - 4.0f,
                                         _dueDateLabel.frame.origin.y,
                                         dueIconImageSize.width,
                                         dueIconImageSize.height);
    
    CGRect usersLabelFrame = CGRectMake(actualBounds.origin.x,
                                         _dueDateLabel.frame.origin.y,
                                         _dueIconImageVIew.frame.origin.x - actualBounds.origin.x,
                                         dueIconImageSize.height);
    
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
                                           CGRectBottom(_fromLabel.frame) + 5.0f,
                                           communityImageSize.width,
                                           communityImageSize.height);
    
    _communityNameTextView.frame = CGRectMake(CGRectRight(_communityImageVIew.frame) + 5.0f,
                                              _communityImageVIew.frame.origin.y + 1.8f,
                                              140,
                                              27.0f);
    
    CGSize messagesImageSize = [_messagesImageVIew image].size;
    _messagesImageVIew.frame = CGRectMake(CGRectRight(_communityNameTextView.frame) + 5.0f,
                                          _communityImageVIew.frame.origin.y + 2.0f,
                                          messagesImageSize.width,
                                          messagesImageSize.height);
    
    _messagesCountLabel.frame = CGRectMake(CGRectRight(_messagesImageVIew.frame) + 5.0f,
                                           _messagesImageVIew.frame.origin.y,
                                           20.0f,
                                           12.0f);
    
    CGFloat statusLabelX = CGRectRight(_messagesCountLabel.frame) + 5.0f;
    _statusLabel.frame = CGRectMake(statusLabelX,
                                    _messagesCountLabel.frame.origin.y,
                                    (actualBounds.origin.x + actualBounds.size.width) - statusLabelX,
                                    _messagesCountLabel.frame.size.height);
}

- (void)setItem:(IQTask *)item {
    _item = item;
    
    _taskIDLabel.text = _item.taskID;
    _titleTextView.text = _item.title;
    _dueDateLabel.text = [_item.dueDate dateToDayTimeString];
    _fromLabel.text = _item.fromUser;
    _toLabel.text = [NSString stringWithFormat:@"> %@", _item.toUser];
    _communityNameTextView.text = _item.communityName;
    _messagesCountLabel.text = [NSString stringWithFormat:@"%@", _item.unreadMessagesCount];
    _statusLabel.text = _item.status;
    
    BOOL isRedStatus = ([_item.status isEqualToString:@"В работе"]);
    _statusLabel.textColor = (isRedStatus) ? [UIColor colorWithHexInt:0xf8931f] : [UIColor colorWithHexInt:0x9f9f9f];
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
