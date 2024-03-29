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
#import "IQAttachment.h"

#define VIEWS_INSET 10.0f
#define ATTACHMENT_VIEW_HEIGHT 15.0f

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
        
    BOOL hasAttachment = ([feedback.attachments count] > 0);
    if(hasAttachment) {
        height += (ATTACHMENT_VIEW_HEIGHT + ATTACHMENT_VIEW_Y_OFFSET) * [feedback.attachments count];
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
    
    for (UIButton * attachButton in _attachButtons) {
        [attachButton removeTarget:nil
                            action:NULL
                  forControlEvents:UIControlEventTouchUpInside];
    }

    [_attachButtons makeObjectsPerformSelector:@selector(removeFromSuperview)];
    [_attachButtons removeAllObjects];
    
    BOOL hasAttachment = ([feedback.attachments count] > 0);
    
    if(hasAttachment) {
        CGFloat attachFontSize = (IS_IPAD) ? 12 : 11.0f;
        for (IQAttachment * attachment in feedback.attachments) {
            UIButton * attachButton = [[UIButton alloc] init];
            [attachButton setImage:[UIImage imageNamed:@"attach_ico.png"] forState:UIControlStateNormal];
            [attachButton.titleLabel setFont:[UIFont fontWithName:IQ_HELVETICA size:attachFontSize]];
            [attachButton setTitleColor:[UIColor colorWithHexInt:0x358bae] forState:UIControlStateNormal];
            [attachButton setTitleColor:[UIColor colorWithHexInt:0x446b7a] forState:UIControlStateHighlighted];
            [attachButton setTitleEdgeInsets:UIEdgeInsetsMake(0.0f, 5.0f, 0.0f, 0.0f)];
            attachButton.contentHorizontalAlignment = UIControlContentHorizontalAlignmentLeft;
            
            NSDictionary *underlineAttribute = @{
                                                 NSFontAttributeName            : [UIFont fontWithName:IQ_HELVETICA size:attachFontSize],
                                                 NSUnderlineStyleAttributeName  : @(NSUnderlineStyleSingle),
                                                 NSForegroundColorAttributeName : [UIColor colorWithHexInt:0x358bae]
                                                 };
            [attachButton setAttributedTitle:[[NSAttributedString alloc] initWithString:attachment.displayName
                                                                             attributes:underlineAttribute]
                                    forState:UIControlStateNormal];
            
            underlineAttribute = @{
                                   NSFontAttributeName            : [UIFont fontWithName:IQ_HELVETICA size:attachFontSize],
                                   NSUnderlineStyleAttributeName  : @(NSUnderlineStyleSingle),
                                   NSForegroundColorAttributeName : [UIColor colorWithHexInt:0x446b7a]
                                   };
            [attachButton setAttributedTitle:[[NSAttributedString alloc] initWithString:attachment.displayName
                                                                             attributes:underlineAttribute]
                                    forState:UIControlStateHighlighted];
            
            [attachButton sizeToFit];
            [self addSubview:attachButton];
            [_attachButtons addObject:attachButton];
        }
    }
}

- (void)layoutSubviews {
    [super layoutSubviews];
    CGRect actualBounds = UIEdgeInsetsInsetRect(self.bounds, _contentInsets);

    CGFloat topLabelsWidth = actualBounds.size.width / 2.0f;
    _dateLabel.frame = CGRectMake(actualBounds.origin.x,
                                  actualBounds.origin.y,
                                  topLabelsWidth,
                                  LABELS_HEIGHT);
    
    _statusLabel.frame = CGRectMake(actualBounds.origin.x + topLabelsWidth,
                                    actualBounds.origin.y,
                                    topLabelsWidth,
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
        CGFloat attachmentX = _descriptionTextView.frame.origin.x;
        CGFloat attachmentY = CGRectBottom(_descriptionTextView.frame) + 5.0f;
        CGSize constrainedSize = CGSizeMake(actualBounds.size.width, ATTACHMENT_VIEW_HEIGHT);
        
        for (UIButton * attachButton in _attachButtons) {
            CGSize attachmentSize = [attachButton sizeThatFits:constrainedSize];
            attachButton.frame = CGRectMake(attachmentX,
                                            attachmentY,
                                            MIN(attachmentSize.width + 5.0f, actualBounds.size.width - attachmentX),
                                            attachmentSize.height);
            
            attachmentY = CGRectBottom(attachButton.frame) + ATTACHMENT_VIEW_Y_OFFSET;
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
