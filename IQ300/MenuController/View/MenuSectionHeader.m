//
//  MenuSectionHeader.m
//  IQ300
//
//  Created by Tayphoon on 07.11.14.
//  Copyright (c) 2014 Tayphoon. All rights reserved.
//

#import "MenuSectionHeader.h"
#import "ExtendedButton.h"
#import "MenuConsts.h"

#define SELECTED_BACKGROUND_COLOR [UIColor colorWithHexInt:0x272d31]

@interface MenuSectionHeader() {
    ExtendedButton * _backgroundView;
    BOOL _isSelected;
    UIEdgeInsets _backgroundViewInsets;
}

@end

@implementation MenuSectionHeader

- (id)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if(self) {
        _backgroundViewInsets = UIEdgeInsetsMake(0, 0, 1, 0);
        CGFloat spacing = 17;

        _backgroundView = [ExtendedButton new];
        _backgroundView.contentHorizontalAlignment = UIControlContentHorizontalAlignmentLeft;
        _backgroundView.contentEdgeInsets = UIEdgeInsetsMake(0, spacing, 0, 0);
        _backgroundView.titleEdgeInsets = UIEdgeInsetsMake(0, 10.0f, 0, 0);
        [_backgroundView setBackgroundColor:MENU_BACKGROUND_COLOR forState:UIControlStateNormal];
        [_backgroundView setBackgroundColor:SELECTED_BACKGROUND_COLOR forState:UIControlStateHighlighted];
        [_backgroundView setImage:[UIImage imageNamed:@"menu_collapseed.png"] forState:UIControlStateNormal];
        [_backgroundView.titleLabel setFont:[UIFont fontWithName:@"Helvetica" size:13]];

        [_backgroundView setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
        [_backgroundView addTarget:self action:@selector(buttonAction:) forControlEvents:UIControlEventTouchUpInside];
        [self addSubview:_backgroundView];
        
        _isSelected = NO;
    }
    return self;
}

- (void)setTitle:(NSString *)title {
    [_backgroundView setTitle:title forState:UIControlStateNormal];
}

- (void)setActionBlock:(void (^)(MenuSectionHeader*))block {
    _actionBlock = [block copy];
}

- (void)setSelected:(BOOL)selected {
    _isSelected = selected;
    [self updateUIForState];
}

- (NSString*)title {
    return [_backgroundView titleForState:UIControlStateNormal];
}

- (void)layoutSubviews {
    [super layoutSubviews];
    
    CGRect backgroundViewRect = UIEdgeInsetsInsetRect(self.bounds, _backgroundViewInsets);
    _backgroundView.frame = backgroundViewRect;
}

- (void)drawRect:(CGRect)rect {
    CGContextRef contex = UIGraphicsGetCurrentContext();

    CGRect bottomLine = CGRectMake(rect.origin.x,
                                   rect.origin.y + rect.size.height - 0.5f,
                                   rect.size.width,
                                   1.0f);

    
    //Draw bottom line
    CGContextSetStrokeColorWithColor(contex, [MENU_SEPARATOR_COLOR CGColor]);
    CGContextSetLineWidth(contex, 1.0f);
    CGContextStrokeRect(contex, bottomLine);
}

- (void)buttonAction:(UIButton*)sender {
    _isSelected = !_isSelected;
    if(_actionBlock) {
        _actionBlock(self);
    }
    [self updateUIForState];
}

- (void)updateUIForState {
    [_backgroundView setBackgroundColor:(_isSelected) ? SELECTED_BACKGROUND_COLOR : MENU_BACKGROUND_COLOR
                               forState:UIControlStateNormal];
    _backgroundView.titleEdgeInsets =  (_isSelected) ? UIEdgeInsetsMake(0, 5.0f, 0, 0) : UIEdgeInsetsMake(0, 10.0f, 0, 0);
    [_backgroundView setImage:(_isSelected) ? [UIImage imageNamed:@"menu_expanded.png"] : [UIImage imageNamed:@"menu_collapseed.png"]
                     forState:UIControlStateNormal];
}

@end
