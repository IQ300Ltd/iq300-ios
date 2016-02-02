//
//  SharingViewController.h
//  IQ300
//
//  Created by Vladislav Grigoryev on 2/1/16.
//  Copyright © 2016 Tayphoon. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "SharingConstants.h"
#import "SharingAttachment.h"

@interface SharingViewController : UINavigationController

- (instancetype)initWithCoder:(NSCoder *)aDecoder NS_UNAVAILABLE;
- (instancetype)initWithNavigationBarClass:(Class)navigationBarClass toolbarClass:(Class)toolbarClass NS_UNAVAILABLE;
- (instancetype)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil NS_UNAVAILABLE ;
- (instancetype)initWithRootViewController:(UIViewController *)rootViewController NS_UNAVAILABLE;

- (instancetype)initWithSharingType:(SharingType)type attachment:(SharingAttachment *)attachment activity:(UIActivity *)activity NS_DESIGNATED_INITIALIZER;

- (void)finishActivity:(BOOL)success;

@end
