//
//  NavigationControllerSubstitutedDelegate.h
//  IQ300
//
//  Created by Viktor Shabanov on 4/7/17.
//  Copyright © 2017 Tayphoon. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface NavigationControllerSubstitutedDelegate : NSObject <UINavigationControllerDelegate>

@property (nonatomic, weak) id<UINavigationControllerDelegate> defaultDelegate;

@end
