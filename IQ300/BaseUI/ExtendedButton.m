//
//  ExtendedButton.m
//  IQ300
//
//  Created by Tayphoon on 07.11.14.
//  Copyright (c) 2014 Tayphoon. All rights reserved.
//

#import "ExtendedButton.h"

#define BORDER_COLOR_KEYPATH @"borderColor"

@interface ExtendedButton() {
    NSMutableDictionary * _backgroundColorsForState;
    NSMutableDictionary * _borderColorsForState;
    NSMutableDictionary * _fontsForState;
    UIControlState _oldState;
    BOOL _isInternalBorderChanges;
}

@end

@implementation ExtendedButton

- (id)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        [self customInit];
    }
    return self;
}

- (void)awakeFromNib {
    [super awakeFromNib];
    [self customInit];
}

- (void)customInit {
    _backgroundColorsForState =  @{ @(UIControlStateNormal)      : [UIColor whiteColor],
                                    @(UIControlStateHighlighted) : [UIColor lightGrayColor] }.mutableCopy ;
    
    _borderColorsForState = [NSMutableDictionary dictionaryWithObjectsAndKeys:[UIColor lightGrayColor], @(UIControlStateNormal), nil];
    _fontsForState = [NSMutableDictionary dictionary];
    
    //Add observer for border color changes
    [self.layer addObserver:self forKeyPath:BORDER_COLOR_KEYPATH options:NSKeyValueObservingOptionNew | NSKeyValueObservingOptionOld context:nil];
    //Add observer for test property(reason: detect button state changed)
    [self.titleLabel addObserver:self forKeyPath:@"text" options:NSKeyValueObservingOptionNew | NSKeyValueObservingOptionOld context:nil];
    
    _isInternalBorderChanges = NO;
    _oldState = self.state;
}

- (void)setBackgroundColor:(UIColor *)backgroundColor {
    [self setBackgroundColor:backgroundColor forState:UIControlStateNormal];
}

- (void)setBackgroundColor:(UIColor *)backgroundColor forState:(UIControlState)state {
    [_backgroundColorsForState setObject:backgroundColor forKey:@(state)];
    if(self.state == state) {
        [super setBackgroundColor:backgroundColor];
    }
}

- (void)setBorderColor:(UIColor *)borderColor forState:(UIControlState)state {
    [_borderColorsForState setObject:borderColor forKey:@(state)];
    if(self.state == state) {
        [self setBorderColor:borderColor.CGColor];
    }
}

- (void)setFont:(UIFont *)font forState:(UIControlState)state {
    [_fontsForState setObject:font forKey:@(state)];
    if(self.state == state) {
        [self.titleLabel setFont:font];
    }
}

- (void)setHighlighted:(BOOL)highlighted {
    super.highlighted = highlighted;
    [self checkState];
}

- (void)setSelected:(BOOL)selected {
    super.selected = selected;
    [self checkState];
}

#pragma mark - Private methods

- (void)setBorderColor:(CGColorRef)borderColor {
    _isInternalBorderChanges = YES;
    [self.layer setBorderColor:borderColor];
    _isInternalBorderChanges = NO;
}

- (void)stateChanged {
    // set background color for new state
    UIColor * backgroundColorForState = [_backgroundColorsForState objectForKey:@(self.state)];
    if(!backgroundColorForState) {
        backgroundColorForState = [_backgroundColorsForState objectForKey:@(UIControlStateNormal)];
    }
    [super setBackgroundColor:backgroundColorForState];
    
    // set border color for new state
    UIColor * borderColorForState = [_borderColorsForState objectForKey:@(self.state)];
    if(!borderColorForState) {
        borderColorForState = [_borderColorsForState objectForKey:@(UIControlStateNormal)];
    }
    [self setBorderColor:borderColorForState.CGColor];
    
    UIFont * fontForState = [_fontsForState objectForKey:@(self.state)];
    fontForState = (!fontForState) ? [_fontsForState objectForKey:@(UIControlStateNormal)] : fontForState;
    if(fontForState) {
        [self.titleLabel setFont:fontForState];
    }
}

- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary *)change context:(void *)context {
    if ([keyPath isEqualToString:BORDER_COLOR_KEYPATH] && !_isInternalBorderChanges) {
        UIColor * borderColor = [UIColor colorWithCGColor:((CALayer*)object).borderColor];
        [self setBorderColor:borderColor forState:UIControlStateNormal];
    }
    else {
        [self checkState];
    }
}

- (void)checkState {
    if(_oldState != self.state) {
        _oldState = self.state;
        [self stateChanged];
    }
}

- (void)dealloc {
    [self.titleLabel removeObserver:self forKeyPath:@"text"];
    [self.layer removeObserver:self forKeyPath:BORDER_COLOR_KEYPATH];
}

@end
