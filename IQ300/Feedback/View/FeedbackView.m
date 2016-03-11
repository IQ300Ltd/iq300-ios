//
//  FeedbackView.m
//  IQ300
//
//  Created by Tayphoon on 30.06.15.
//  Copyright (c) 2015 Tayphoon. All rights reserved.
//

#import "FeedbackView.h"
#import "IQManagedFeedback.h"
#import "IQFeedbackType.h"
#import "IQFeedbackCategory.h"
#import "IQUser.h"
#import "NSDate+IQFormater.h"
#import "IQManagedAttachment.h"
#import "IQAttachmentButton.h"

#define VIEWS_INSET 10.0f

#define INLINE_SPACE_MIN 15.0f
#define INTERLINE_SPACE 15.0f

#define ITEM_HEIGHT 120.0f
#define ITEM_WIDHT 85.0f

#define ATTACHEMENTS_OFFSET 15.0f

#define FEEDBACK_ATTACHEMENT_HORIZONTAL_INSETS 17.0f

#ifdef IPAD
#define TYPE_FONT [UIFont fontWithName:IQ_HELVETICA_BOLD size:17.0f]
#define TYPE_HEIGHT 19.0f
#define LABELS_FONT [UIFont fontWithName:IQ_HELVETICA size:15.0f]
#define LABELS_HEIGHT 17.0f
#define ATTACHMENT_VIEW_Y_OFFSET 7.0f
#define LABELS_OFFSET 7.0f
#else
#define TYPE_FONT [UIFont fontWithName:IQ_HELVETICA_BOLD size:15.0f]
#define TYPE_HEIGHT 17.0f
#define LABELS_FONT [UIFont fontWithName:IQ_HELVETICA size:13.0f]
#define LABELS_HEIGHT 15.0f
#define ATTACHMENT_VIEW_Y_OFFSET 7.0f
#define LABELS_OFFSET 7.0f
#endif

@interface FeedbackView() {
    UIEdgeInsets _contentInsets;
    NSMutableArray * _attachButtons;
}

@end

@implementation FeedbackView

+ (CGFloat)heightForFeedback:(IQManagedFeedback*)feedback width:(CGFloat)width {
    CGFloat viewWidth = width - VIEWS_INSET * 2.0f;
    CGFloat height = VIEWS_INSET * 3 + (LABELS_HEIGHT + LABELS_OFFSET) * 3 + TYPE_HEIGHT + LABELS_OFFSET * 2;
    
    if([feedback.feedbackDescription length] > 0) {
        UITextView * descriptionTextView = [[UITextView alloc] init];
        [descriptionTextView setFont:LABELS_FONT];
        descriptionTextView.textContainer.lineFragmentPadding = 0;
        descriptionTextView.textContainerInset = UIEdgeInsetsZero;
        descriptionTextView.text = feedback.feedbackDescription;
        
        CGSize descriptionSize = [descriptionTextView sizeThatFits:CGSizeMake(viewWidth, CGFLOAT_MAX)];
        height += descriptionSize.height;
    }
    
    CGFloat actualWidth = viewWidth - FEEDBACK_ATTACHEMENT_HORIZONTAL_INSETS * 2.0f;
    
    NSUInteger itemsCountPerRow = (NSUInteger)((actualWidth + INLINE_SPACE_MIN) / (ITEM_WIDHT + INLINE_SPACE_MIN));
    NSUInteger itemsCount = feedback.attachments.count;
    
    NSUInteger rowsCount = itemsCount / itemsCountPerRow + (itemsCount % itemsCountPerRow != 0 ? 1 : 0);
    
    if (rowsCount > 0) {
        height += rowsCount * (ITEM_HEIGHT + INTERLINE_SPACE) - INTERLINE_SPACE + ATTACHEMENTS_OFFSET;
    }
    return height;
}

- (id)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        self.backgroundColor = [UIColor whiteColor];
        _attachButtons = [NSMutableArray array];
        _contentInsets = UIEdgeInsetsMakeWithInset(VIEWS_INSET);

        _dateLabel = [self makeLabelWithTextColor:[UIColor colorWithHexInt:0x9f9f9f]
                                             font:LABELS_FONT
                                    localaizedKey:nil];
        [self addSubview:_dateLabel];

        _statusLabel = [self makeLabelWithTextColor:[UIColor colorWithHexInt:0x9f9f9f]
                                               font:LABELS_FONT
                                      localaizedKey:nil];
        _statusLabel.textAlignment = NSTextAlignmentRight;
        [self addSubview:_statusLabel];
        
        _messagesImageView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"message_blue_buble.png"]];
        [self addSubview:_messagesImageView];
        
        _commentsCountLabel = [self makeLabelWithTextColor:[UIColor colorWithHexInt:0x272727]
                                                      font:LABELS_FONT
                                             localaizedKey:nil];
        [self addSubview:_commentsCountLabel];
        
        _feedbackTypeLabel = [self makeLabelWithTextColor:[UIColor colorWithHexInt:0x272727]
                                                     font:TYPE_FONT
                                            localaizedKey:nil];
        [self addSubview:_feedbackTypeLabel];

        _feedbackCategoryLabel = [self makeLabelWithTextColor:[UIColor colorWithHexInt:0x272727]
                                                         font:LABELS_FONT
                                                localaizedKey:nil];
        [self addSubview:_feedbackCategoryLabel];

        _authorLabel = [self makeLabelWithTextColor:[UIColor colorWithHexInt:0x9f9f9f]
                                               font:LABELS_FONT
                                      localaizedKey:nil];
        [self addSubview:_authorLabel];

        _descriptionTextView = [[IQTextView alloc] init];
        [_descriptionTextView setFont:LABELS_FONT];
        [_descriptionTextView setTextColor:[UIColor colorWithHexInt:0x272727]];
        _descriptionTextView.textAlignment = NSTextAlignmentLeft;
        _descriptionTextView.backgroundColor = [UIColor clearColor];
        _descriptionTextView.editable = NO;
        _descriptionTextView.textContainerInset = UIEdgeInsetsZero;
        _descriptionTextView.scrollEnabled = NO;
        _descriptionTextView.dataDetectorTypes = UIDataDetectorTypeLink;
        _descriptionTextView.textContainer.lineFragmentPadding = 0;
        _descriptionTextView.linkTextAttributes = @{
                                                    NSForegroundColorAttributeName: [UIColor colorWithHexInt:0x358bae],
                                                    NSUnderlineStyleAttributeName: @(NSUnderlineStyleSingle)
                                                    };
        [self addSubview:_descriptionTextView];
        
        
    }
    return self;
}

- (void)drawRect:(CGRect)rect {
    CGContextRef context = UIGraphicsGetCurrentContext();
    
    CGFloat boardRectY = VIEWS_INSET + (LABELS_HEIGHT + LABELS_OFFSET) * 3 + TYPE_HEIGHT + LABELS_OFFSET;
    CGRect boardRect = CGRectMake(rect.origin.x,
                                  boardRectY,
                                  rect.size.width,
                                  rect.size.height - boardRectY);
    
    CGFloat lineHeight = 0.5f;
    CGRect toLineRect = CGRectMake(boardRect.origin.x,
                                   boardRect.origin.y,
                                   boardRect.size.width,
                                   lineHeight);
    
    CGContextSetFillColorWithColor(context, [UIColor colorWithHexInt:0xf6f6f6].CGColor);
    CGContextFillRect(context, boardRect);

    //Draw top line
    CGContextSetStrokeColorWithColor(context, [[UIColor colorWithHexInt:0xc0c0c0] CGColor]);
    CGContextSetLineWidth(context, lineHeight);
    CGContextStrokeRect(context, toLineRect);
}

- (NSArray*)attachButtons {
    return [_attachButtons copy];
}

- (void)updateViewWithFeedback:(IQManagedFeedback*)feedback {
    _dateLabel.text = [feedback.createdDate dateToDayString];
    NSString * statusKey = [NSString stringWithFormat:@"%@_%@", @"feedback", feedback.state];
    _statusLabel.text = NSLocalizedString(statusKey, nil);
    _feedbackTypeLabel.text = feedback.feedbackType.title;
    _feedbackCategoryLabel.text = NSLocalizedStringWithFormat(@"Category: %@", feedback.category.title);
    _authorLabel.text = feedback.author.displayName;
    _descriptionTextView.text = feedback.feedbackDescription;
    
    BOOL showCommentsCount = ([feedback.commentsCount integerValue] > 0);
    _commentsCountLabel.hidden = !showCommentsCount;
    _messagesImageView.hidden = !showCommentsCount;
    _commentsCountLabel.text = [feedback.commentsCount stringValue];
    
    for (UIButton * attachButton in _attachButtons) {
        [attachButton removeTarget:nil
                            action:NULL
                  forControlEvents:UIControlEventTouchUpInside];
    }

    [_attachButtons makeObjectsPerformSelector:@selector(removeFromSuperview)];
    [_attachButtons removeAllObjects];
    
    BOOL hasAttachment = ([feedback.attachments count] > 0);
    
    if(hasAttachment) {
        for (IQManagedAttachment * attachment in feedback.attachments) {
            IQAttachmentButton *attachmentButton = [[IQAttachmentButton alloc] initWithFrame:CGRectZero];
            [attachmentButton setItem:attachment isMine:YES];
            [self addSubview:attachmentButton];
            [_attachButtons addObject:attachmentButton];
        }
    }
}

- (void)layoutSubviews {
    [super layoutSubviews];
    CGRect actualBounds = UIEdgeInsetsInsetRect(self.bounds, _contentInsets);

    CGSize dateLabelSize = [_dateLabel sizeThatFits:CGSizeMake(actualBounds.size.width, LABELS_HEIGHT)];
    
    CGSize messagesImageSize = [_messagesImageView.image size];
    CGSize messagesTextSize = [_commentsCountLabel sizeThatFits:CGSizeMake(actualBounds.size.width, CGFLOAT_MAX)];
    
    CGFloat maximalHeight = MAX(MAX(messagesImageSize.height, messagesTextSize.height), dateLabelSize.height);
    
    _dateLabel.frame = CGRectMake(actualBounds.origin.x,
                                  actualBounds.origin.y + (maximalHeight - dateLabelSize.height) / 2.0f,
                                  dateLabelSize.width,
                                  dateLabelSize.height);
    CGFloat labelOffset = 5.0f;
    _messagesImageView.frame = CGRectMake(actualBounds.origin.x + (actualBounds.size.width - messagesImageSize.width - messagesTextSize.width - labelOffset) / 2.0f,
                                          actualBounds.origin.y + (maximalHeight - messagesImageSize.height) / 2.0f,
                                          messagesImageSize.width,
                                          messagesImageSize.height);
    
    _commentsCountLabel.frame = CGRectMake(CGRectRight(_messagesImageView.frame) + labelOffset,
                                           actualBounds.origin.y + (maximalHeight - messagesTextSize.height) / 2.0f,
                                           messagesTextSize.width,
                                           messagesTextSize.height);

    _statusLabel.frame = CGRectMake(CGRectRight(_commentsCountLabel.frame),
                                    actualBounds.origin.y,
                                    actualBounds.size.width - CGRectRight(_commentsCountLabel.frame),
                                    LABELS_HEIGHT);
    
    _feedbackTypeLabel.frame = CGRectMake(actualBounds.origin.x,
                                          CGRectBottom(_dateLabel.frame) + LABELS_OFFSET,
                                          actualBounds.size.width,
                                          TYPE_HEIGHT);
    
    _feedbackCategoryLabel.frame = CGRectMake(actualBounds.origin.x,
                                          CGRectBottom(_feedbackTypeLabel.frame) + LABELS_OFFSET,
                                          actualBounds.size.width,
                                          LABELS_HEIGHT);

    _authorLabel.frame = CGRectMake(actualBounds.origin.x,
                                    CGRectBottom(_feedbackCategoryLabel.frame) + LABELS_OFFSET,
                                    actualBounds.size.width,
                                    LABELS_HEIGHT);
    
    CGSize descriptionSize = [_descriptionTextView sizeThatFits:CGSizeMake(actualBounds.size.width, CGFLOAT_MAX)];
    
    _descriptionTextView.frame = CGRectMake(actualBounds.origin.x,
                                            CGRectBottom(_authorLabel.frame) + LABELS_OFFSET * 2,
                                            actualBounds.size.width,
                                            descriptionSize.height);
    
    
    
    BOOL hasAttachment = ([_attachButtons count] > 0);
    if(hasAttachment) {
        CGRect attachementActualBounds = CGRectMake(FEEDBACK_ATTACHEMENT_HORIZONTAL_INSETS,
                                                    CGRectBottom(_descriptionTextView.frame) + ATTACHEMENTS_OFFSET,
                                                    self.bounds.size.width - FEEDBACK_ATTACHEMENT_HORIZONTAL_INSETS * 2.0f,
                                                    CGFLOAT_MAX);
        NSUInteger itemsCountPerRow = (NSUInteger)((attachementActualBounds.size.width + INLINE_SPACE_MIN) / (ITEM_WIDHT + INLINE_SPACE_MIN));
        CGFloat inlineSpace = (attachementActualBounds.size.width - (itemsCountPerRow * ITEM_WIDHT)) / (itemsCountPerRow > 1 ? (itemsCountPerRow - 1) : 1);
        
        CGFloat xPosition = attachementActualBounds.origin.x;
        CGFloat xStep = ITEM_WIDHT + inlineSpace;
        
        CGFloat yPosition = attachementActualBounds.origin.y;
        CGFloat yStep = ITEM_HEIGHT + INTERLINE_SPACE;
        
        for (IQAttachmentButton *button in _attachButtons) {
            button.frame = CGRectMake(xPosition, yPosition, ITEM_WIDHT, ITEM_HEIGHT);
            
            xPosition += xStep;
            if (xPosition >= CGRectRight(attachementActualBounds)) {
                xPosition = attachementActualBounds.origin.x;
                yPosition += yStep;
            }
        }
    }
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
