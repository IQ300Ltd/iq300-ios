//
//  AttachmentView.m
//  IQ300
//
//  Created by Vladislav Grigoryev on 09/02/16.
//  Copyright © 2016 Tayphoon. All rights reserved.
//

#import "IQAttachmentButton.h"
#import "IQAttachment.h"
#import <UIImageView+WebCache.h>

@implementation IQAttachmentButton

- (instancetype)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        _customImageView = [[UIImageView alloc] initWithFrame:CGRectZero];
        [self addSubview:_customImageView];
        
        _label = [[UILabel alloc] initWithFrame:CGRectZero];
        [_label setNumberOfLines:2];
        [_label setLineBreakMode:NSLineBreakByTruncatingMiddle];
        [_label setTextAlignment:NSTextAlignmentCenter];
        [_label setFont:[UIFont fontWithName:IQ_HELVETICA size:(IS_IPAD) ? 12 : 11.0f]];
        [_label setTextColor:[UIColor blackColor]];
        
        [self addSubview:_label];
        
        self.layer.cornerRadius = 5.0f;
        self.layer.masksToBounds = YES;
        
        self.layer.borderColor = [UIColor colorWithRed:0.0f green:0.0f blue:0.0f alpha:0.5f].CGColor;
        self.layer.borderWidth = 0.5f;
        
        _defaultColor = [UIColor colorWithHexInt:0xcaddee];
        _mineColor = [UIColor colorWithHexInt:0xe0e0e0];
    }
    return self;
}

- (void)layoutSubviews {
    [super layoutSubviews];
    
    CGSize size = self.bounds.size;
    
    CGFloat labelHeight = size.height - size.width;
    
    [_customImageView setFrame:CGRectMake(0, 0, size.width, size.height - labelHeight)];
    [_label setFrame:CGRectMake(2.0f, size.height - labelHeight, size.width - 4.0f, labelHeight)];
}

- (void)setItem:(IQAttachment *)attachment isMine:(BOOL)isMine {
    UIImage *plasehodler = [UIImage imageNamed:@"document_placeholder"];
    
    if (attachment.previewURL && attachment.previewURL.length > 0) {
        __weak typeof(self) weakSelf = self;
        [_customImageView sd_setImageWithURL:[NSURL URLWithString:attachment.previewURL]
                      placeholderImage:plasehodler
                               options:0
                             completed:^(UIImage *image,
                                         NSError *error,
                                         SDImageCacheType
                                         cacheType,
                                         NSURL *imageURL) {
                                 [weakSelf setNeedsLayout];
                             }];
    }
    else {
        [_customImageView setImage:plasehodler];
    }
    
    self.backgroundColor = isMine ? _mineColor : _defaultColor;
    
    [_label setText:attachment.displayName];
    
    [self setNeedsLayout];
}


@end
