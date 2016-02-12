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
@property (nonatomic, strong) NSLayoutConstraint *widthConstraint;

@end

@implementation IQUtilityButtonView

- (id)initWithUtilityButtons:(NSArray *)utilityButtons parentCell:(SWTableViewCell *)parentCell utilityButtonSelector:(SEL)utilityButtonSelector {
    return [self initWithFrame:CGRectZero utilityButtons:utilityButtons parentCell:parentCell utilityButtonSelector:utilityButtonSelector];
}

- (id)initWithFrame:(CGRect)frame utilityButtons:(NSArray *)utilityButtons parentCell:(SWTableViewCell *)parentCell utilityButtonSelector:(SEL)utilityButtonSelector {
    self = [super initWithFrame:frame];
    
    if (self) {
        self.translatesAutoresizingMaskIntoConstraints = NO;
        
        self.widthConstraint = [NSLayoutConstraint constraintWithItem:self
                                                            attribute:NSLayoutAttributeWidth
                                                            relatedBy:NSLayoutRelationEqual
                                                               toItem:nil
                                                            attribute:NSLayoutAttributeNotAnAttribute
                                                           multiplier:1.0
                                                             constant:0.0]; // constant will be adjusted dynamically in -setUtilityButtons:.
        self.widthConstraint.priority = UILayoutPriorityDefaultHigh;
        [self addConstraint:self.widthConstraint];

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
    
    NSEnumerator *enumerator = self.utilityButtons.objectEnumerator;
    UIButton * firstButton = [enumerator nextObject];
    CGRect prevRect = CGRectMake(self.buttonOffset.x,
                                 (self.frame.size.height - firstButton.frame.size.height) / 2.0f,
                                 firstButton.frame.size.width,
                                 firstButton.frame.size.height);
    
    firstButton.frame = prevRect;
    UIButton * button = nil;
    while (button = [enumerator nextObject]) {
        CGRect nextRect = CGRectMake(CGRectRight(prevRect) + self.buttonOffset.x,
                                     prevRect.origin.y + self.buttonOffset.y,
                                     button.frame.size.width,
                                     button.frame.size.height);
        
        button.frame = nextRect;
        prevRect = nextRect;
    }
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
    
    if (utilityButtons.count)
    {
        NSUInteger utilityButtonsCounter = 0;
        
        for (UIButton *button in self.utilityButtons)
        {
            [self addSubview:button];
            SWUtilityButtonTapGestureRecognizer *utilityButtonTapGestureRecognizer = [[SWUtilityButtonTapGestureRecognizer alloc] initWithTarget:_parentCell action:self.utilityButtonSelector];
            utilityButtonTapGestureRecognizer.buttonIndex = utilityButtonsCounter;
            [button addGestureRecognizer:utilityButtonTapGestureRecognizer];
            
            utilityButtonsCounter++;
        }
    }
    
    self.widthConstraint.constant = (width * utilityButtons.count);
    
    [self setNeedsLayout];
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
