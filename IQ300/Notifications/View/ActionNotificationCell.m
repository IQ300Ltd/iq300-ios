//
//  ActionNotificationCell.m
//  IQ300
//
//  Created by Tayphoon on 22.12.14.
//  Copyright (c) 2014 Tayphoon. All rights reserved.
//
#import <QuartzCore/QuartzCore.h>

#import "ActionNotificationCell.h"
#import "IQUtilityButtonView.h"

static NSString * const kTableViewCellContentView = @"UITableViewCellContentView";

@interface ActionNotificationCell()

@property (nonatomic, strong) SWUtilityButtonView *leftUtilityButtonsView, *rightUtilityButtonsView;
@property (nonatomic, readonly) UIView *leftUtilityClipView, *rightUtilityClipView;
@property (nonatomic, readonly) NSLayoutConstraint *leftUtilityClipConstraint, *rightUtilityClipConstraint;
@property (nonatomic, readonly) UIScrollView *cellScrollView;

@end

@implementation ActionNotificationCell

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier {
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if(self) {
        [self setBackgroundColor:[UIColor colorWithHexInt:0xf6f6f6]];
        
        [self.leftUtilityButtonsView removeFromSuperview];
        self.leftUtilityButtonsView = [[IQUtilityButtonView alloc] initWithUtilityButtons:nil
                                                                               parentCell:self
                                                                    utilityButtonSelector:@selector(leftUtilityButtonHandler:)];

        [self.rightUtilityButtonsView removeFromSuperview];
        self.rightUtilityButtonsView = [[IQUtilityButtonView alloc] initWithUtilityButtons:nil
                                                                                parentCell:self
                                                                     utilityButtonSelector:@selector(rightUtilityButtonHandler:)];
        
        UIView *contentViewParent = self;
        UIView *clipViewParent = self.cellScrollView;
        if (![NSStringFromClass([[self.subviews objectAtIndex:0] class]) isEqualToString:kTableViewCellContentView])
        {
            // iOS 7
            contentViewParent = [self.subviews objectAtIndex:0];
            clipViewParent = self;
        }

        UIView *clipViews[] = { self.rightUtilityClipView, self.leftUtilityClipView };
        NSLayoutConstraint *clipConstraints[] = { self.rightUtilityClipConstraint, self.leftUtilityClipConstraint };
        UIView *buttonViews[] = { self.rightUtilityButtonsView, self.leftUtilityButtonsView };
        NSLayoutAttribute alignmentAttributes[] = { NSLayoutAttributeRight, NSLayoutAttributeLeft };
        
        for (NSUInteger i = 0; i < 2; ++i)
        {
            UIView *clipView = clipViews[i];
            NSLayoutConstraint *clipConstraint = clipConstraints[i];
            UIView *buttonView = buttonViews[i];
            NSLayoutAttribute alignmentAttribute = alignmentAttributes[i];
            
            clipConstraint.priority = UILayoutPriorityDefaultHigh;
            
            clipView.translatesAutoresizingMaskIntoConstraints = NO;
            clipView.clipsToBounds = YES;
            
            [clipViewParent addSubview:clipView];
            [self addConstraints:@[
                                   // Pin the clipping view to the appropriate outer edges of the cell.
                                   [NSLayoutConstraint constraintWithItem:clipView attribute:NSLayoutAttributeTop relatedBy:NSLayoutRelationEqual toItem:self attribute:NSLayoutAttributeTop multiplier:1.0 constant:0.0],
                                   [NSLayoutConstraint constraintWithItem:clipView attribute:NSLayoutAttributeBottom relatedBy:NSLayoutRelationEqual toItem:self attribute:NSLayoutAttributeBottom multiplier:1.0 constant:0.0],
                                   [NSLayoutConstraint constraintWithItem:clipView attribute:alignmentAttribute relatedBy:NSLayoutRelationEqual toItem:self attribute:alignmentAttribute multiplier:1.0 constant:0.0],
                                   clipConstraint,
                                   ]];
            
            [clipView addSubview:buttonView];
            [self addConstraints:@[
                                   // Pin the button view to the appropriate outer edges of its clipping view.
                                   [NSLayoutConstraint constraintWithItem:buttonView attribute:NSLayoutAttributeTop relatedBy:NSLayoutRelationEqual toItem:clipView attribute:NSLayoutAttributeTop multiplier:1.0 constant:0.0],
                                   [NSLayoutConstraint constraintWithItem:buttonView attribute:NSLayoutAttributeBottom relatedBy:NSLayoutRelationEqual toItem:clipView attribute:NSLayoutAttributeBottom multiplier:1.0 constant:0.0],
                                   [NSLayoutConstraint constraintWithItem:buttonView attribute:alignmentAttribute relatedBy:NSLayoutRelationEqual toItem:clipView attribute:alignmentAttribute multiplier:1.0 constant:0.0],
                                   
                                   // Constrain the maximum button width so that at least a button's worth of contentView is left visible. (The button view will shrink accordingly.)
                                   [NSLayoutConstraint constraintWithItem:buttonView attribute:NSLayoutAttributeWidth relatedBy:NSLayoutRelationLessThanOrEqual toItem:self.contentView attribute:NSLayoutAttributeWidth multiplier:1.0 constant:-kUtilityButtonWidthDefault],
                                   ]];
        }

    }
    return self;
}

- (void)setItem:(IQNotification *)item {
    [super setItem:item];
    
    UIButton * okButton = [[UIButton alloc] initWithFrame:CGRectMake(0.0f, 0.0f, 99.0f, 31.0f)];
    okButton.layer.cornerRadius = 3.0f;
    [okButton setClipsToBounds:YES];
    okButton.titleLabel.font = [UIFont fontWithName:IQ_HELVETICA size:10];
    [okButton setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    [okButton setBackgroundColor:[UIColor colorWithHexInt:0x40b549]];
    [okButton setTitle:@"На доработку" forState:UIControlStateNormal];
    
    UIButton * cancelButton = [[UIButton alloc] initWithFrame:CGRectMake(0.0f, 0.0f, 99.0f, 31.0f)];
    cancelButton.layer.cornerRadius = 3.0f;
    [cancelButton setClipsToBounds:YES];
    cancelButton.titleLabel.font = [UIFont fontWithName:IQ_HELVETICA size:10];
    [cancelButton setTitleColor:[UIColor colorWithHexInt:0x338cae] forState:UIControlStateNormal];
    [cancelButton setBackgroundColor:[UIColor whiteColor]];
    [cancelButton setTitle:@"На доработку" forState:UIControlStateNormal];

    self.rightUtilityButtons = @[okButton , cancelButton];
    [self setNeedsLayout];
}

- (UIView*)leftUtilityClipView {
    return [super valueForKey:@"_leftUtilityClipView"];
}

- (UIView*)rightUtilityClipView {
    return [super valueForKey:@"_rightUtilityClipView"];
}

- (UIScrollView*)cellScrollView {
    return [super valueForKey:@"_cellScrollView"];
}

- (NSLayoutConstraint*)leftUtilityClipConstraint {
    return [super valueForKey:@"_leftUtilityClipConstraint"];
}

- (NSLayoutConstraint*)rightUtilityClipConstraint {
    return [super valueForKey:@"_rightUtilityClipConstraint"];
}

@end
