//
//  MenuSectionHeader.m
//  IQ300
//
//  Created by Tayphoon on 07.11.14.
//  Copyright (c) 2014 Tayphoon. All rights reserved.
//
#import <JSBadgeView/JSBadgeView.h>

#import "MenuSectionHeader.h"
#import "ExtendedButton.h"
#import "MenuConsts.h"

#define SELECTED_BACKGROUND_COLOR [UIColor colorWithHexInt:0x272d31]

@interface MenuSectionHeader() {
    ExtendedButton * _backgroundView;
    BOOL _isExpandable;
    UIEdgeInsets _backgroundViewInsets;
}

@end

@implementation MenuSectionHeader

- (id)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if(self) {
        _backgroundViewInsets = UIEdgeInsetsMake(0, 0, 1, 0);
        CGFloat spacing = 17;
        
        [self setBottomLineColor:MENU_SEPARATOR_COLOR];
        [self setBottomLineHeight:1.0f];

        _backgroundView = [ExtendedButton new];
        _backgroundView.contentHorizontalAlignment = UIControlContentHorizontalAlignmentLeft;
        _backgroundView.contentEdgeInsets = UIEdgeInsetsMake(0, spacing, 0, 0);
        _backgroundView.titleEdgeInsets = UIEdgeInsetsMake(0, 10.0f, 0, 0);
        [_backgroundView setBackgroundColor:MENU_BACKGROUND_COLOR forState:UIControlStateNormal];
        [_backgroundView setBackgroundColor:SELECTED_BACKGROUND_COLOR forState:UIControlStateHighlighted];
        [_backgroundView setImage:[UIImage imageNamed:@"menu_collapseed.png"] forState:UIControlStateNormal];
        [_backgroundView.titleLabel setFont:[UIFont fontWithName:@"Helvetica" size:14]];

        [_backgroundView setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
        [_backgroundView addTarget:self action:@selector(buttonAction:) forControlEvents:UIControlEventTouchUpInside];
        [self addSubview:_backgroundView];
        
        _badgeView = [[JSBadgeView alloc] initWithParentView:self alignment:JSBadgeViewAlignmentCenterRight];
        _badgeView.badgePositionAdjustment = CGPointMake(-20, 0);
        _badgeView.badgeBackgroundColor = [UIColor whiteColor];
        _badgeView.badgeTextColor = [UIColor colorWithHexInt:0x459dbe];
        _badgeView.badgeStrokeColor = [UIColor colorWithHexInt:0x338cae];
        _badgeView.badgeStrokeWidth = 1.0f;
        _badgeView.badgeTextFont = [UIFont fontWithName:@"Helvetica" size:16];
        
        _selected = NO;
        _expanded = NO;
        [self updateUIForState];
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
    if(_selected != selected) {
        _selected = selected;
        [self updateUIForState];
    }
}

- (void)setExpandable:(BOOL)expandable {
    if(_isExpandable != expandable) {
        _isExpandable = expandable;
        [self updateUIForState];
    }
}

- (void)setExpanded:(BOOL)expanded {
    if(_expanded != expanded) {
        _expanded = expanded;
        [self updateUIForState];
    }
}

- (NSString*)title {
    return [_backgroundView titleForState:UIControlStateNormal];
}

- (void)layoutSubviews {
    [super layoutSubviews];
    
    CGRect actualBounds = self.bounds;
    CGRect backgroundViewRect = UIEdgeInsetsInsetRect(actualBounds, _backgroundViewInsets);
    _backgroundView.frame = backgroundViewRect;
    
    _badgeView.frame = CGRectMake(actualBounds.origin.x + actualBounds.size.width - actualBounds.size.height,
                                  0,
                                  actualBounds.size.height,
                                  actualBounds.size.height);

}

- (void)buttonAction:(UIButton*)sender {
    _selected = !_selected;
    _expanded = !_expanded;
    if(_actionBlock) {
        _actionBlock(self);
    }
    [self updateUIForState];
}

- (void)updateUIForState {
    [_backgroundView setBackgroundColor:(_selected) ? SELECTED_BACKGROUND_COLOR : MENU_BACKGROUND_COLOR
                               forState:UIControlStateNormal];
    
    if(_isExpandable) {
    _backgroundView.titleEdgeInsets = (_expanded) ? UIEdgeInsetsMake(0, 5.0f, 0, 0) : UIEdgeInsetsMake(0, 10.0f, 0, 0);
    [_backgroundView setImage:(_expanded) ? [UIImage imageNamed:@"menu_expanded.png"] : [UIImage imageNamed:@"menu_collapseed.png"]
                     forState:UIControlStateNormal];
    }
    else {
        _backgroundView.titleEdgeInsets = UIEdgeInsetsZero;
        [_backgroundView setImage:nil forState:UIControlStateNormal];
    }
}

@end
