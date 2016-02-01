//
//  SharingViewController.h
//  IQ300
//
//  Created by Vladislav Grigoryev on 2/1/16.
//  Copyright © 2016 Tayphoon. All rights reserved.
//

#import <UIKit/UIKit.h>

typedef NS_ENUM(NSInteger, SharingType) {
    SharingTypeMessages,
    SharingTypeTasks,
};

@class IQAttachment;

@interface SharingNavigationController : UINavigationController

- (instancetype)initWithCoder:(NSCoder *)aDecoder NS_UNAVAILABLE;
- (instancetype)initWithNavigationBarClass:(Class)navigationBarClass toolbarClass:(Class)toolbarClass NS_UNAVAILABLE;
- (instancetype)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil NS_UNAVAILABLE ;
- (instancetype)initWithRootViewController:(UIViewController *)rootViewController NS_UNAVAILABLE;

- (instancetype)initWithSharingType:(SharingType)type attachments:(IQAttachment *)attachment NS_DESIGNATED_INITIALIZER;

@end
