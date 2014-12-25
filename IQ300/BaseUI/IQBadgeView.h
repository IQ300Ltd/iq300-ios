//
//  IQBadgeView.h
//  IQ300
//
//  Created by Tayphoon on 25.11.14.
//  Copyright (c) 2014 Tayphoon. All rights reserved.
//

#import "IQBadgeStyle.h"

@interface IQBadgeView : UIView

@property (nonatomic, strong) UIFont * badgeTextFont;
@property (nonatomic, assign) CGFloat badgeMinSize;
@property (nonatomic, assign) CGFloat frameLineHeight;
@property (nonatomic, copy)   NSString * badgeValue;    // default is nil
@property (nonatomic) IQBadgeStyle * badgeStyle;
@property (nonatomic,readwrite) CGFloat badgeCornerRoundness;
@property (nonatomic,readwrite) CGFloat badgeScaleFactor;

+ (IQBadgeView*)customBadgeWithString:(NSString *)badgeString;
+ (IQBadgeView*)customBadgeWithString:(NSString *)badgeString badgeMinSize:(CGFloat)badgeMinSize;
+ (IQBadgeView*)customBadgeWithString:(NSString *)badgeString withStyle:(IQBadgeStyle*)style;
+ (IQBadgeView*)customBadgeWithString:(NSString *)badgeString withScale:(CGFloat)scale;
+ (IQBadgeView*)customBadgeWithString:(NSString *)badgeString withScale:(CGFloat)scale withStyle:(IQBadgeStyle*)style;

@end
