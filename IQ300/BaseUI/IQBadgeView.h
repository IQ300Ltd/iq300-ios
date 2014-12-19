//
//  IQBadgeView.h
//  IQ300
//
//  Created by Tayphoon on 25.11.14.
//  Copyright (c) 2014 Tayphoon. All rights reserved.
//

#import <CustomBadge/CustomBadge.h>

@interface IQBadgeView : CustomBadge

@property (nonatomic, strong) UIFont * badgeTextFont;
@property (nonatomic, assign) CGFloat badgeMinSize;
@property (nonatomic, assign) CGFloat frameLineHeight;
@property(nonatomic,copy) NSString *badgeValue;    // default is nil

+ (IQBadgeView*)customBadgeWithString:(NSString *)badgeString;
+ (IQBadgeView*)customBadgeWithString:(NSString *)badgeString badgeMinSize:(CGFloat)badgeMinSize;
+ (IQBadgeView*)customBadgeWithString:(NSString *)badgeString withStyle:(BadgeStyle*)style;

@end
