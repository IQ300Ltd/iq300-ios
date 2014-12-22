//
//  IQUtilityButtonView.m
//  IQ300
//
//  Created by Tayphoon on 22.12.14.
//  Copyright (c) 2014 Tayphoon. All rights reserved.
//
#import <SWUtilityButtonTapGestureRecognizer.h>

#import "IQUtilityButtonView.h"

@interface IQUtilityButtonView() {
    SWTableViewCell * _parentCell;
}

@property (nonatomic, strong) NSMutableArray *buttonBackgroundColors;

@end

@implementation IQUtilityButtonView

- (id)initWithUtilityButtons:(NSArray *)utilityButtons parentCell:(SWTableViewCell *)parentCell utilityButtonSelector:(SEL)utilityButtonSelector {
    return [self initWithFrame:CGRectZero utilityButtons:utilityButtons parentCell:parentCell utilityButtonSelector:utilityButtonSelector];
}

- (id)initWithFrame:(CGRect)frame utilityButtons:(NSArray *)utilityButtons parentCell:(SWTableViewCell *)parentCell utilityButtonSelector:(SEL)utilityButtonSelector {
    self = [super initWithFrame:frame];
    
    if (self) {
        _parentCell = parentCell;
        self.utilityButtonSelector = utilityButtonSelector;
        self.utilityButtons = utilityButtons;
    }
    
    return self;
}

- (SWTableViewCell*)parentCell {
    return _parentCell;
}

- (void)layoutSubviews {
    [super layoutSubviews];
}

#pragma mark Populating utility buttons

- (void)setUtilityButtons:(NSArray *)utilityButtons
{
    // if no width specified, use the default width
    [self setUtilityButtons:utilityButtons WithButtonWidth:kUtilityButtonWidthDefault];
}

- (void)setUtilityButtons:(NSArray *)utilityButtons WithButtonWidth:(CGFloat)width {
    for (UIButton *button in self.utilityButtons) {
        [button removeFromSuperview];
    }
    
    [super setValue:[utilityButtons copy] forKey:@"_utilityButtons"];
    
    if (utilityButtons.count) {
        NSUInteger utilityButtonsCounter = 0;
        
        for (UIButton *button in self.utilityButtons)
        {
            SWUtilityButtonTapGestureRecognizer * tapGestureRecognizer = [[SWUtilityButtonTapGestureRecognizer alloc] initWithTarget:self.parentCell
                                                                                                                               action:self.utilityButtonSelector];
            tapGestureRecognizer.buttonIndex = utilityButtonsCounter;
            [button addGestureRecognizer:tapGestureRecognizer];
            utilityButtonsCounter++;
            [self addSubview:button];
        }
    }
        
    [self setNeedsLayout];
    
    return;
}

#pragma mark -

- (void)pushBackgroundColors {
    self.buttonBackgroundColors = [[NSMutableArray alloc] init];
    
    for (UIButton *button in self.utilityButtons)
    {
        [self.buttonBackgroundColors addObject:button.backgroundColor];
    }
}

- (void)popBackgroundColors {
    NSEnumerator *e = self.utilityButtons.objectEnumerator;
    
    for (UIColor *color in self.buttonBackgroundColors)
    {
        UIButton *button = [e nextObject];
        button.backgroundColor = color;
    }
    
    self.buttonBackgroundColors = nil;
}

@end
