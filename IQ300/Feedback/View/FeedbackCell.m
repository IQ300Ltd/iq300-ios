//
//  FeedbackCell.m
//  IQ300
//
//  Created by Tayphoon on 26.06.15.
//  Copyright (c) 2015 Tayphoon. All rights reserved.
//

#import "FeedbackCell.h"
#import "IQManagedFeedback.h"
#import "IQFeedbackType.h"
#import "IQFeedbackCategory.h"
#import "IQUser.h"
#import "NSDate+IQFormater.h"

#ifdef IPAD
#define TITLE_FONT [UIFont fontWithName:IQ_HELVETICA_BOLD size:12.0f]
#define LABELS_FONT [UIFont fontWithName:IQ_HELVETICA size:12.0f]
#define LABELS_HEIGHT 15.0f
#else
#define TITLE_FONT [UIFont fontWithName:IQ_HELVETICA_BOLD size:11.0f]
#define LABELS_FONT [UIFont fontWithName:IQ_HELVETICA size:11.0f]
#define LABELS_HEIGHT 13.0f
#endif

@interface FeedbackCell() {
    UIEdgeInsets _contentInsets;
}

@end

@implementation FeedbackCell

+ (NSString*)imageNameForFeedbackType:(NSString*)type {
    static NSDictionary * _imageNames = nil;
    static dispatch_once_t oncePredicate;
    dispatch_once(&oncePredicate, ^{
        _imageNames = @{
                                @"proposal" : @"feedback_proposal_type.png",
                                @"question" : @"feedback_question_type.png",
                                @"error"    : @"feedback_error_type.png"
                                };
    });
    
    if([_imageNames objectForKey:type]) {
        return [_imageNames objectForKey:type];
    }
    
    return nil;
}


- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier {
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    
    if(self) {
        self.selectionStyle = UITableViewCellSelectionStyleNone;
        
        UIView * contentView = self.contentView;
        
        _contentInsets = UIEdgeInsetsMakeWithInset(10.0f);
        _typeImageView = [[UIImageView alloc] init];
        [contentView addSubview:_typeImageView];

        _titleLabel = [self makeLabelWithTextColor:[UIColor colorWithHexInt:0x272727]
                                              font:[UIFont fontWithName:IQ_HELVETICA_BOLD size:11]
                                     localaizedKey:nil];
        [contentView addSubview:_titleLabel];
        
        _dateLabel = [self makeLabelWithTextColor:[UIColor colorWithHexInt:0x272727]
                                              font:LABELS_FONT
                                     localaizedKey:nil];
        [contentView addSubview:_dateLabel];
        
        _descriptionLabel = [self makeLabelWithTextColor:[UIColor colorWithHexInt:0x272727]
                                                    font:LABELS_FONT
                                           localaizedKey:nil];
        [contentView addSubview:_descriptionLabel];
        
        _attachImageView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"attachment_img"]];
        [contentView addSubview:_attachImageView];
        
        _authorLabel = [self makeLabelWithTextColor:[UIColor colorWithHexInt:0x9f9f9f]
                                               font:LABELS_FONT
                                      localaizedKey:nil];
        [contentView addSubview:_authorLabel];
        
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
    }
    return self;
}

+ (CGFloat)heightForItem:(IQManagedFeedback *)item andCellWidth:(CGFloat)cellWidth {
    return 78;
}

- (void)setItem:(IQManagedFeedback *)item {
    _item = item;

    NSString * typeImageName = [FeedbackCell imageNameForFeedbackType:_item.feedbackType.type];
    _typeImageView.image = [UIImage imageNamed:typeImageName];
    _dateLabel.text = [_item.createdDate dateToDayString];
    _titleLabel.text = [NSString stringWithFormat:@"%@, %@", _item.feedbackType.title, _item.category.title];
    _descriptionLabel.text = _item.feedbackDescription;
    _authorLabel.text = _item.author.displayName;
    _commentsCountLabel.text = @"34";
    _attachImageView.hidden = ([_item.attachments count] == 0);
    _statusLabel.text = _item.state;
}

- (void)layoutSubviews {
    [super layoutSubviews];
    
    CGRect bounds = self.contentView.bounds;
    CGRect actualBounds = UIEdgeInsetsInsetRect(bounds, _contentInsets);

    CGFloat labelsHorizonalInset = 7.0f;
    CGFloat labelsOffset = 5.0f;
    CGFloat typeImageSize = 15.0f;
    _typeImageView.frame = CGRectMake(actualBounds.origin.x,
                                      actualBounds.origin.y,
                                      typeImageSize,
                                      typeImageSize);
    
    CGFloat dateMaxWidth = 150;
    CGSize dateLabelSize = [_dateLabel.text sizeWithFont:_dateLabel.font
                                       constrainedToSize:CGSizeMake(dateMaxWidth, typeImageSize)
                                           lineBreakMode:NSLineBreakByWordWrapping];
    
    CGFloat dateLabelWidth = MIN(dateLabelSize.width, dateMaxWidth);
    _dateLabel.frame = CGRectMake(actualBounds.origin.x + actualBounds.size.width - dateLabelSize.width,
                                  actualBounds.origin.y,
                                  dateLabelWidth,
                                  LABELS_HEIGHT);

    
    CGFloat titleX = CGRectRight(_typeImageView.frame) + labelsOffset;
    _titleLabel.frame = CGRectMake(titleX,
                                   actualBounds.origin.x,
                                   _dateLabel.frame.origin.x - titleX - labelsOffset,
                                   _dateLabel.frame.size.height);
    
    CGSize attachmentSize = CGSizeMake(15, 13);
    _attachImageView.frame = CGRectMake(actualBounds.origin.x + actualBounds.size.width - attachmentSize.width,
                                        CGRectBottom(_dateLabel.frame) + labelsHorizonalInset,
                                        attachmentSize.width,
                                        attachmentSize.height);
    
    _descriptionLabel.frame = CGRectMake(actualBounds.origin.x,
                                         _attachImageView.frame.origin.y,
                                         _attachImageView.frame.origin.x - actualBounds.origin.x - labelsOffset,
                                         LABELS_HEIGHT);
    
    CGFloat boundsCenterX = (actualBounds.origin.x + actualBounds.size.width) / 2.0f;
    CGFloat labelsMaxWidth = boundsCenterX / 2.0f;
    CGFloat bottomLabelsY = CGRectBottom(_descriptionLabel.frame) + labelsHorizonalInset;

    CGSize messagesImageSize = [_messagesImageView image].size;
    _messagesImageView.frame = CGRectMake(boundsCenterX,
                                          bottomLabelsY,
                                          messagesImageSize.width,
                                          messagesImageSize.height);
    
    CGSize constrainedSize = CGSizeMake(labelsMaxWidth, LABELS_HEIGHT);
    CGSize statusLabelSize = [_statusLabel.text sizeWithFont:_statusLabel.font
                                           constrainedToSize:constrainedSize
                                               lineBreakMode:NSLineBreakByWordWrapping];
    
    _statusLabel.frame = CGRectMake((actualBounds.origin.x + actualBounds.size.width) - statusLabelSize.width,
                                    _messagesImageView.frame.origin.y,
                                    statusLabelSize.width,
                                    LABELS_HEIGHT);
    
    CGFloat countMaxWidth = labelsMaxWidth - messagesImageSize.width - labelsOffset;
    countMaxWidth = MAX(countMaxWidth, _statusLabel.frame.origin.x - CGRectRight(_messagesImageView.frame) - labelsOffset);
    
    _commentsCountLabel.frame = CGRectMake(CGRectRight(_messagesImageView.frame) + labelsOffset,
                                           _messagesImageView.frame.origin.y,
                                           countMaxWidth,
                                           messagesImageSize.height);
    
    _authorLabel.frame = CGRectMake(actualBounds.origin.x,
                                    bottomLabelsY,
                                    boundsCenterX - actualBounds.origin.x - labelsOffset,
                                    LABELS_HEIGHT);
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
