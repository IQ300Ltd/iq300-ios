//
//  AccountHeaderView.m
//  IQ300
//
//  Created by Tayphoon on 07.11.14.
//  Copyright (c) 2014 Tayphoon. All rights reserved.
//

#import "AccountHeaderView.h"
#import "MenuConsts.h"

@implementation AccountHeaderView

- (id)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if(self) {
        self.bottomLineColor = MENU_SEPARATOR_COLOR;
        self.bottomLineHeight = 1.0f;
        [self setBackgroundColor:MENU_BACKGROUND_COLOR];
    }
    return self;
}

@end
