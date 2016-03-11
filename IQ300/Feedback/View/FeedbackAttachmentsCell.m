//
//  FeedbackAttachmentsCell.m
//  IQ300
//
//  Created by Vladislav Grigoryev on 02/03/16.
//  Copyright © 2016 Tayphoon. All rights reserved.
//

#import "FeedbackAttachmentsCell.h"
#import "IQEditableTextCell.h"

#define INLINE_SPACE_MIN 15.0f
#define INTERLINE_SPACE 15.0f

#define ITEM_HEIGHT 120.0f
#define ITEM_WIDHT 85.0f

#define FEEDBACK_ATTACHEMENT_HORIZONTAL_INSETS 17.5f

#define LABEL_TEXT NSLocalizedString(@"Attachments", nil)
#define ADD_ATTACHMENT_IMAGE_NAME @"plus.png"

@interface FeedbackAttachmentsCell()

@property (nonatomic, strong) NSMutableArray *mutableButtons;

@property (nonatomic, assign) UIEdgeInsets contentInsets;
@property (nonatomic, assign) CGSize itemSize;

@end

@implementation FeedbackAttachmentsCell

+ (CGFloat)heightForItems:(NSArray<__kindof id<IQAttachment>> *)items cellWidth:(CGFloat)cellWidth showAddButton:(BOOL)show{
    
    CGFloat actualWidth = cellWidth - FEEDBACK_ATTACHEMENT_HORIZONTAL_INSETS * 2.0f;
    
    NSUInteger itemsCountPerRow = (NSUInteger)((actualWidth + INLINE_SPACE_MIN) / (ITEM_WIDHT + INLINE_SPACE_MIN));
    NSUInteger itemsCount = items.count;
    
    NSUInteger rowsCount = itemsCount / itemsCountPerRow + (itemsCount % itemsCountPerRow != 0 ? 1 : 0);
    
    NSUInteger resultHeight = CELL_MIN_HEIGHT;
    if (rowsCount > 0) {
        resultHeight += rowsCount * (ITEM_HEIGHT + INTERLINE_SPACE) - INTERLINE_SPACE + CONTENT_VERTICAL_INSETS * 2.0f;
    }
    
    return resultHeight;
}

- (instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier {
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        _mutableButtons = [[NSMutableArray alloc] init];
        _contentInsets = UIEdgeInsetsMake(CONTENT_VERTICAL_INSETS, FEEDBACK_ATTACHEMENT_HORIZONTAL_INSETS, CONTENT_VERTICAL_INSETS, FEEDBACK_ATTACHEMENT_HORIZONTAL_INSETS);
        _itemSize = CGSizeMake(ITEM_WIDHT, ITEM_HEIGHT);
        _addButtonShown = NO;
        
        _titleView = [[UIView alloc] initWithFrame:CGRectZero];
        _titleView.backgroundColor = [UIColor colorWithHexInt:0xf6f6f6];
        [self.contentView addSubview:_titleView];
        
        self.backgroundColor = [UIColor colorWithHexInt:0xf6f6f6];

        
        _label = [[UILabel alloc] initWithFrame:CGRectZero];
        [_label setFont:TEXT_FONT];
        [_label setTextColor:TEXT_COLOR];
        [_label setText:LABEL_TEXT];
        [_titleView addSubview:_label];
        
        _addButton = [[UIButton alloc] initWithFrame:CGRectZero];
        [_addButton setImage:[UIImage imageNamed:ADD_ATTACHMENT_IMAGE_NAME] forState:UIControlStateNormal];
        [_titleView addSubview:_addButton];
        
        self.selectionStyle = UITableViewCellSelectionStyleNone;
    }
    return self;
}

- (void)setAddButtonShown:(BOOL)addButtonShown {
    _addButtonShown = addButtonShown;
    [self setNeedsLayout];
}

- (NSArray<__kindof IQAttachmentButton*> *)buttons {
    return [_mutableButtons copy];
}

- (void)setItems:(NSArray<__kindof id<IQAttachment>> *)items {
    [_mutableButtons makeObjectsPerformSelector:@selector(removeFromSuperview)];
    [_mutableButtons removeAllObjects];
    
    for (id<IQAttachment> item in items) {
        IQAttachmentButton *attachmentButton = [[IQAttachmentButton alloc] initWithFrame:CGRectZero];
        [attachmentButton setItem:item isMine:YES showDeleteButton:YES];
        [_mutableButtons addObject:attachmentButton];
        [self.contentView addSubview:attachmentButton];
    }
}

- (void)prepareForReuse {
    [super prepareForReuse];
    
    [_addButton removeTarget:nil
                      action:NULL
            forControlEvents:UIControlEventAllEvents];
    
    [_mutableButtons makeObjectsPerformSelector:@selector(removeFromSuperview)];
    [_mutableButtons removeAllObjects];
}

- (void)layoutSubviews {
    [super layoutSubviews];
    
    _titleView.frame = CGRectMake(0, 0, self.bounds.size.width, CELL_MIN_HEIGHT);
    
    CGRect titleViewActualBounds = UIEdgeInsetsInsetRect(_titleView.frame, _contentInsets);
    CGSize labelSize = [_label sizeThatFits:titleViewActualBounds.size];
    CGSize imageSize = CGSizeMake(15.0f, 15.0f);
    
    _label.frame = CGRectMake(titleViewActualBounds.origin.x,
                              titleViewActualBounds.origin.y + (titleViewActualBounds.size.height - labelSize.height) / 2.0f,
                              labelSize.width,
                              labelSize.height);
    
    _addButton.frame = CGRectMake(self.bounds.size.width - CELL_MIN_HEIGHT,
                                  0,
                                  CELL_MIN_HEIGHT,
                                  CELL_MIN_HEIGHT);

    _addButton.imageEdgeInsets = UIEdgeInsetsMake((CELL_MIN_HEIGHT - imageSize.height) / 2.0f,
                                                  (CELL_MIN_HEIGHT - imageSize.width) / 2.0f,
                                                  (CELL_MIN_HEIGHT - imageSize.height) / 2.0f,
                                                  (CELL_MIN_HEIGHT - imageSize.width) / 2.0f);
    _addButton.hidden = !_addButtonShown;
    
    
    CGRect actualBounds = UIEdgeInsetsInsetRect(self.bounds, _contentInsets);
    actualBounds.origin.y += CELL_MIN_HEIGHT;

    NSUInteger itemsCountPerRow = (NSUInteger)((actualBounds.size.width + INLINE_SPACE_MIN) / (_itemSize.width + INLINE_SPACE_MIN));
    CGFloat inlineSpace = (actualBounds.size.width - (itemsCountPerRow * _itemSize.width)) / (itemsCountPerRow > 1 ? (itemsCountPerRow - 1) : 1);
    
    CGFloat xPosition = actualBounds.origin.x;
    CGFloat xStep = _itemSize.width + inlineSpace;
    
    CGFloat yPosition = actualBounds.origin.y;
    CGFloat yStep = _itemSize.height + INTERLINE_SPACE;
    
    for (IQAttachmentButton *button in _mutableButtons) {
        button.frame = CGRectMake(xPosition, yPosition, _itemSize.width, _itemSize.height);
        
        xPosition += xStep;
        if (xPosition >= CGRectRight(actualBounds)) {
            xPosition = actualBounds.origin.x;
            yPosition += yStep;
        }
    }
    

}


@end
