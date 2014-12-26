//
//  IQBadgeStyle.h
//  IQ300
//
//  Created by Tayphoon on 25.12.14.
//  Copyright (c) 2014 Tayphoon. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface IQBadgeStyle : NSObject {

}

@property(nonatomic, strong) UIColor * badgeTextColor;
@property(nonatomic, strong) UIColor * badgeInsetColor;
@property(nonatomic, strong) UIColor * badgeFrameColor;
@property(nonatomic, assign) BOOL badgeFrame;
@property(nonatomic, assign) BOOL badgeShining;
@property(nonatomic, assign) BOOL badgeShadow;

+ (IQBadgeStyle*)defaultStyle;
+ (IQBadgeStyle*)oldStyle;
+ (IQBadgeStyle*)freeStyleWithTextColor:(UIColor*)textColor
                         withInsetColor:(UIColor*)insetColor
                         withFrameColor:(UIColor*)frameColor
                              withFrame:(BOOL)frame
                             withShadow:(BOOL)shadow
                            withShining:(BOOL)shining;

@end
