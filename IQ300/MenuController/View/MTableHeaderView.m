//
//  MTableHeaderView.m
//  IQ300
//
//  Created by Tayphoon on 10.11.14.
//  Copyright (c) 2014 Tayphoon. All rights reserved.
//

#import "MTableHeaderView.h"
#import "MenuConsts.h"

@interface MTableHeaderView () {
    UILabel * _titleLabel;
}

@end

@implementation MTableHeaderView

- (id)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if(self) {
        
        _contentInsets = UIEdgeInsetsMake(0, 15, 0, 0);
        self.bottomLineColor = MENU_SEPARATOR_COLOR;
        self.bottomLineHeight = 1.0f;
        [self setBackgroundColor:MENU_BACKGROUND_COLOR];
        
        _titleLabel = [[UILabel alloc] init];
        [_titleLabel setFont:[UIFont fontWithName:IQ_HELVETICA size:15]];
        [_titleLabel setTextColor:[UIColor whiteColor]];
        _titleLabel.textAlignment = NSTextAlignmentLeft;
        _titleLabel.backgroundColor = [UIColor clearColor];
        _titleLabel.numberOfLines = 0;
        _titleLabel.lineBreakMode = NSLineBreakByWordWrapping;
        [_titleLabel setText:NSLocalizedString(@"Tasks", @"Tasks")];
        [self addSubview:_titleLabel];
    }
    return self;
}


- (void)setTitle:(NSString *)title {
    _titleLabel.text = title;
}

- (NSString*)title {
    return _titleLabel.text;
}

- (void)layoutSubviews {
    [super layoutSubviews];
    _titleLabel.frame = UIEdgeInsetsInsetRect(self.bounds, _contentInsets);
}

@end
