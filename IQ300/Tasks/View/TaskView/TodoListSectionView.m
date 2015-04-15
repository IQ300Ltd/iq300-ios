//
//  TodoListSectionView.m
//  IQ300
//
//  Created by Tayphoon on 19.03.15.
//  Copyright (c) 2015 Tayphoon. All rights reserved.
//

#import "TodoListSectionView.h"

@implementation TodoListSectionView

- (id)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if(self) {
        _contentInsets = UIEdgeInsetsHorizontalMake(13.0f);
        
        self.backgroundColor = [UIColor colorWithHexInt:0xf6f6f6];
        self.bottomLineHeight = 0.5f;
        self.bottomLineColor = [UIColor colorWithHexInt:0xc0c0c0];

        _titleLabel = [[UILabel alloc] init];
        [_titleLabel setFont:[UIFont fontWithName:IQ_HELVETICA size:15]];
        [_titleLabel setTextColor:[UIColor colorWithHexInt:0x272727]];
        _titleLabel.textAlignment = NSTextAlignmentLeft;
        _titleLabel.backgroundColor = [UIColor clearColor];
        _titleLabel.numberOfLines = 1;
        _titleLabel.lineBreakMode = NSLineBreakByTruncatingTail;
        _titleLabel.text = NSLocalizedString(@"TodoList", nil);
        [self addSubview:_titleLabel];
        
        _editButton = [[UIButton alloc] init];
        [_editButton setImage:[UIImage imageNamed:@"edit_gray_ico.png"] forState:UIControlStateNormal];
        [self addSubview:_editButton];
    }
    return self;
}

- (void)layoutSubviews {
    [super layoutSubviews];
    
    CGRect bounds = self.bounds;
    CGRect actualBounds = UIEdgeInsetsInsetRect(bounds, _contentInsets);

    CGSize editImageSize = [_editButton imageForState:UIControlStateNormal].size;
    CGSize editSize = CGSizeMake(actualBounds.size.height, actualBounds.size.height);
    _editButton.frame = CGRectMake(actualBounds.origin.x + actualBounds.size.width - (editSize.width - editImageSize.width),
                                   actualBounds.origin.y + (actualBounds.size.height - editSize.height) / 2.0f,
                                   editSize.width,
                                   editSize.height);
    
    _titleLabel.frame = CGRectMake(actualBounds.origin.x,
                                   actualBounds.origin.y,
                                   _editButton.frame.origin.x,
                                   actualBounds.size.height);
}

@end
