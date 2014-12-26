//
//  IQBadgeStyle.m
//  IQ300
//
//  Created by Tayphoon on 25.12.14.
//  Copyright (c) 2014 Tayphoon. All rights reserved.
//

#import "IQBadgeStyle.h"

@implementation IQBadgeStyle

+ (IQBadgeStyle*)defaultStyle {
    id instance = [[super alloc] init];
    [instance setBadgeTextColor:[UIColor whiteColor]];
    [instance setBadgeInsetColor:[UIColor redColor]];
    [instance setBadgeFrameColor:nil];
    [instance setBadgeFrame:NO];
    [instance setBadgeShadow:NO];
    [instance setBadgeShining:NO];
    return instance;
}

+ (IQBadgeStyle*)oldStyle {
    id instance = [[super alloc] init];
    [instance setBadgeTextColor:[UIColor whiteColor]];
    [instance setBadgeInsetColor:[UIColor redColor]];
    [instance setBadgeFrameColor:[UIColor whiteColor]];
    [instance setBadgeFrame:YES];
    [instance setBadgeShadow:YES];
    [instance setBadgeShining:YES];
    return instance;
}

+ (IQBadgeStyle*)freeStyleWithTextColor:(UIColor*)textColor
                         withInsetColor:(UIColor*)insetColor
                         withFrameColor:(UIColor*)frameColor
                              withFrame:(BOOL)frame
                             withShadow:(BOOL)shadow
                            withShining:(BOOL)shining {
    id instance = [[super alloc] init];
    [instance setBadgeTextColor:textColor];
    [instance setBadgeInsetColor:insetColor];
    [instance setBadgeFrameColor:frameColor];
    [instance setBadgeFrame:frame];
    [instance setBadgeShadow:shadow];
    [instance setBadgeShining:shining];
    return instance;
}

@end
