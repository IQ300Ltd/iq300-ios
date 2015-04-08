//
//  UIViewController+Additions.m
//  IQ300
//
//  Created by Tayphoon on 08.04.15.
//  Copyright (c) 2015 Tayphoon. All rights reserved.
//

#import "UIViewController+Additions.h"

@implementation UIViewController (Additions)

- (BOOL)isVisible {
    return [self isViewLoaded] && self.view.window;
}

@end
