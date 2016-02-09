//
//  AttachmentsView.m
//  IQ300
//
//  Created by Vladislav Grigoryev on 09/02/16.
//  Copyright © 2016 Tayphoon. All rights reserved.
//

#import "IQAttachmentsView.h"
#import "IQAttachmentButton.h"

#define ITEM_SPACING 5.0f

#define ITEM_WIDTH 75.0f

@interface IQAttachmentsView()

@property (nonatomic, strong) NSMutableArray<__kindof IQAttachmentButton *> *attachemntViews;

@end

@implementation IQAttachmentsView

- (instancetype)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        _attachemntViews = [[NSMutableArray alloc] init];
    
        _scrollView = [[UIScrollView alloc] initWithFrame:CGRectZero];
        [_scrollView setShowsHorizontalScrollIndicator:NO];
        [self addSubview:_scrollView];
    }
    return self;
}

- (void)layoutSubviews {
    [super layoutSubviews];
    
    CGSize size = self.bounds.size;
    [_scrollView setFrame:CGRectMake(0, 0, size.width, size.height)];

    CGFloat contentWidth = ITEM_WIDTH * _attachemntViews.count + ITEM_SPACING * (_attachemntViews.count - 1);
    [_scrollView setContentSize:CGSizeMake(contentWidth, size.height)];
    
    NSInteger counter = 0;
    for (IQAttachmentButton *view in _attachemntViews) {
        [view setFrame:CGRectMake((ITEM_WIDTH + ITEM_SPACING) *counter, 0, ITEM_WIDTH, size.height)];
        counter++;
    }
}

- (void)setItems:(NSArray<__kindof IQAttachment *> *)items isMine:(BOOL)isMine{
    [_attachemntViews makeObjectsPerformSelector:@selector(removeFromSuperview)];
    [_attachemntViews removeAllObjects];
    
    for (IQAttachment *attachment in items) {
        IQAttachmentButton *attachmentView = [[IQAttachmentButton alloc] initWithFrame:CGRectZero];
        [attachmentView setItem:attachment isMine:isMine];
        [_scrollView addSubview:attachmentView];
        [_attachemntViews addObject:attachmentView];
    }
    [self setNeedsLayout];
}

- (NSArray *)attachmentButtons {
    return [_attachemntViews copy];
}

- (BOOL)hasAttachments {
    return _attachemntViews.count > 0;
}

@end
