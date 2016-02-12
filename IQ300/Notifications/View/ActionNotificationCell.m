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
#import "IQNotification.h"
#import "NotificationsHelper.h"

@interface ActionNotificationCell() {
    IQUtilityButtonView * _leftButtonsView;
    IQUtilityButtonView * _rightButtonsView;
    UIView * _readFlagView;
}

@end

@implementation ActionNotificationCell

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier {
    [self initUtilityButtonViews];
    
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if(self) {
        [self setBackgroundColor:[UIColor colorWithHexInt:0xf6f6f6]];
        
        _readFlagView = [[UIView alloc] init];
        [_readFlagView setBackgroundColor:READ_FLAG_COLOR];
        [self insertSubview:_readFlagView atIndex:0];
    }
    return self;
}

- (void)layoutSubviews {
    [super layoutSubviews];
    
    CGRect bounds = self.contentView.bounds;
    _readFlagView.frame = CGRectMake(0.0f,
                                     0.0f,
                                     READ_FLAG_WIDTH,
                                     bounds.size.height);
}

- (void)setItem:(IQNotification *)item {
    [super setItem:item];
    
    _contentBackgroundInsets = (![item.hasActions boolValue]) ? UIEdgeInsetsZero : UIEdgeInsetsMake(0, READ_FLAG_WIDTH, 0, 0);
    self.contentBackgroundView.backgroundColor = (![item.hasActions boolValue]) ? CONTEN_BACKGROUND_COLOR_R :
                                                                                  CONTEN_BACKGROUND_COLOR;

    if([item.hasActions boolValue]) {
        NSMutableArray * actionButtons = [NSMutableArray array];
        NSMutableArray * availableActions = [NSMutableArray array];
        
        //Set right order for actions
        for (NSString * actionType in item.availableActions) {
            BOOL isPositiveAction = [NotificationsHelper isPositiveActionWithType:actionType];
            if(isPositiveAction) {
                [availableActions insertObject:actionType atIndex:0];
            }
            else {
                [availableActions addObject:actionType];
            }
        }
        
        for (NSString * actionType in availableActions) {
            BOOL isPositiveAction = [NotificationsHelper isPositiveActionWithType:actionType];
            NSString * combineType = ([item.notificable.type length] > 0) ? [NSString stringWithFormat:@"%@_%@", item.notificable.type, actionType] :
            actionType;
            NSString * localizeKey = [NotificationsHelper displayNameForActionType:[combineType lowercaseString]];
            UIButton * actionButton = [[UIButton alloc] initWithFrame:CGRectMake(0.0f, 0.0f, 99.0f, 31.0f)];
            actionButton.layer.cornerRadius = 3.0f;
            if(!isPositiveAction) {
                actionButton.layer.borderWidth = 0.5f;
                actionButton.layer.borderColor = [UIColor colorWithHexInt:0xd0d0d0].CGColor;
                [actionButton setTitleColor:[UIColor colorWithHexInt:0x338cae] forState:UIControlStateNormal];
                [actionButton setBackgroundColor:[UIColor whiteColor]];
            }
            else {
                [actionButton setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
                [actionButton setBackgroundColor:[UIColor colorWithHexInt:0x40b549]];
            }
            
            actionButton.titleLabel.font = [UIFont fontWithName:IQ_HELVETICA size:10];
            [actionButton setTitle:NSLocalizedString(localizeKey, nil) forState:UIControlStateNormal];
            [actionButton setClipsToBounds:YES];
            [actionButtons addObject:actionButton];
        }
        
        [self setRightUtilityButtons:actionButtons WithButtonWidth:116.0f];
        self.leftUtilityButtons = nil;
    }
    [self setNeedsLayout];
}

- (SWUtilityButtonView*)leftUtilityButtonsView {
    return _leftButtonsView;
}

- (SWUtilityButtonView*)rightUtilityButtonsView {
    return _rightButtonsView;
}

#pragma mark - Private methods

- (void)initUtilityButtonViews {
#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Wundeclared-selector"
    _leftButtonsView = [[IQUtilityButtonView alloc] initWithUtilityButtons:nil
                                                                parentCell:self
                                                     utilityButtonSelector:@selector(leftUtilityButtonHandler:)];
    _leftButtonsView.buttonOffset = CGPointMake(10.0f, 0.0f);
    
    _rightButtonsView = [[IQUtilityButtonView alloc] initWithUtilityButtons:nil
                                                                 parentCell:self
                                                      utilityButtonSelector:@selector(rightUtilityButtonHandler:)];
    _rightButtonsView.buttonOffset = CGPointMake(10.0f, 0.0f);
#pragma clang diagnostic pop
}

@end
