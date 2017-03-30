//
//  TAttachmentCell.m
//  IQ300
//
//  Created by Tayphoon on 20.03.15.
//  Copyright (c) 2015 Tayphoon. All rights reserved.
//

#import "TAttachmentCell.h"
#import "IQManagedAttachment.h"
#import "IQAttachmentButton.h"

#define CONTEN_BACKGROUND_COLOR [UIColor colorWithHexInt:0xe0e0e0]
#define CONTEN_BACKGROUND_COLOR_HIGHLIGHTED IQ_BACKGROUND_P3_COLOR
#define NEW_FLAG_COLOR IQ_BACKGROUND_P4_COLOR
#define NEW_FLAG_WIDTH 4.0f

@interface TAttachmentCell()

@property (nonatomic, strong) IQAttachmentButton *button;

@end

@implementation TAttachmentCell

- (instancetype)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        [self setBackgroundColor:[UIColor clearColor]];
        
        _button = [[IQAttachmentButton alloc] initWithFrame:CGRectZero];
        _button.mineColor = CONTEN_BACKGROUND_COLOR_HIGHLIGHTED;
        _button.defaultColor = CONTEN_BACKGROUND_COLOR;
        [_button setEnabled:NO];
        [self.contentView addSubview:_button];
    }
    return self;
}

- (void)setItem:(IQManagedAttachment *)item {
    _item = item;
    
    BOOL unread = [item.unread boolValue];
    [_button setItem:item isMine:unread];
    [self setNeedsLayout];
}

- (void)layoutSubviews {
    [super layoutSubviews];
    
    [_button setFrame:self.bounds];
}

@end
