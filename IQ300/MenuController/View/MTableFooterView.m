//
//  MTableFooterView.m
//  IQ300
//
//  Created by Tayphoon on 24.06.15.
//  Copyright (c) 2015 Tayphoon. All rights reserved.
//

#import "MTableFooterView.h"
#import "MenuConsts.h"
#import "ExtendedButton.h"

#define SELECTED_BACKGROUND_COLOR [UIColor colorWithHexInt:0x272d31]

@interface MTableFooterView () {
    ExtendedButton * _backgroundView;
}

@end

@implementation MTableFooterView

- (id)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if(self) {
        
        CGFloat spacing = 13;
        _contentInsets = UIEdgeInsetsMake(1, 0, 0, 0);
        self.topLineColor = MENU_SEPARATOR_COLOR;
        self.topLineHeight = 1.0f;
        [self setBackgroundColor:MENU_BACKGROUND_COLOR];
        
        _backgroundView = [ExtendedButton new];
        _backgroundView.contentHorizontalAlignment = UIControlContentHorizontalAlignmentLeft;
        _backgroundView.contentEdgeInsets = UIEdgeInsetsMake(0, spacing, 0, 0);
        [_backgroundView setBackgroundColor:MENU_BACKGROUND_COLOR forState:UIControlStateNormal];
        [_backgroundView setBackgroundColor:SELECTED_BACKGROUND_COLOR forState:UIControlStateHighlighted];
        [_backgroundView.titleLabel setFont:[UIFont fontWithName:@"Helvetica" size:14]];
        
        [_backgroundView setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
        [_backgroundView addTarget:self action:@selector(buttonAction:) forControlEvents:UIControlEventTouchUpInside];
        [self addSubview:_backgroundView];

        [self updateUIForState];
    }
    return self;
}

- (NSString*)title {
    return [_backgroundView titleForState:UIControlStateNormal];
}

- (void)setTitle:(NSString *)title {
    [_backgroundView setTitle:title forState:UIControlStateNormal];
}

- (void)setActionBlock:(void (^)(MTableFooterView*))block {
    _actionBlock = [block copy];
}

- (void)setSelected:(BOOL)selected {
    if(_selected != selected) {
        _selected = selected;
        [self updateUIForState];
    }
}

- (void)layoutSubviews {
    [super layoutSubviews];
    
    CGRect actualBounds = self.bounds;
    CGRect backgroundViewRect = UIEdgeInsetsInsetRect(actualBounds, _contentInsets);
    _backgroundView.frame = backgroundViewRect;
}

- (void)drawRect:(CGRect)rect {
    CGContextRef contex = UIGraphicsGetCurrentContext();
    
    CGRect toLineRect = CGRectMake(rect.origin.x,
                                   rect.origin.y,
                                   rect.size.width,
                                   _topLineHeight);

    //Draw top line
    CGContextSetStrokeColorWithColor(contex, [_topLineColor CGColor]);
    CGContextSetLineWidth(contex, _topLineHeight);
    CGContextStrokeRect(contex, toLineRect);
}

#pragma mark - Private methods

- (void)buttonAction:(UIButton*)sender {
    if(_selectable) {
        _selected = !_selected;
    }
    if(_actionBlock) {
        _actionBlock(self);
    }
    [self updateUIForState];
}

- (void)updateUIForState {
    if (_selectable) {
        [_backgroundView setBackgroundColor:(_selected) ? SELECTED_BACKGROUND_COLOR : MENU_BACKGROUND_COLOR
                                   forState:UIControlStateNormal];
    }
}

@end

