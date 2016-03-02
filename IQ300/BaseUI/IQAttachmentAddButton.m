//
//  IQAttachmentAddButton.m
//  IQ300
//
//  Created by Vladislav Grigoryev on 02/03/16.
//  Copyright © 2016 Tayphoon. All rights reserved.
//

#import "IQAttachmentAddButton.h"

@implementation IQAttachmentAddButton

- (instancetype)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        _customImageView = [[UIImageView alloc] initWithFrame:CGRectZero];
        _customImageView.image = [UIImage imageNamed:@"add_attachment_icon.png"];
        [self addSubview:_customImageView];
        
        _label = [[UILabel alloc] initWithFrame:CGRectZero];
        [_label setNumberOfLines:2];
        [_label setLineBreakMode:NSLineBreakByTruncatingMiddle];
        [_label setTextAlignment:NSTextAlignmentCenter];
        [_label setFont:[UIFont fontWithName:IQ_HELVETICA size:(IS_IPAD) ? 12 : 11.0f]];
        [_label setTextColor:[UIColor blackColor]];
        [_label setText:NSLocalizedString(@"Add attachment", nil)];
        
        [self addSubview:_label];
        
        self.layer.cornerRadius = 5.0f;
        self.layer.masksToBounds = YES;
        
        self.layer.borderColor = [UIColor colorWithRed:0.0f green:0.0f blue:0.0f alpha:0.5f].CGColor;
        self.layer.borderWidth = 0.5f;
        self.backgroundColor = [UIColor colorWithHexInt:0xe0e0e0];
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

@end
