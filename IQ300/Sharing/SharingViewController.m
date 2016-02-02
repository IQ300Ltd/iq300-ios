//
//  SharingViewController.m
//  IQ300
//
//  Created by Vladislav Grigoryev on 2/1/16.
//  Copyright © 2016 Tayphoon. All rights reserved.
//

#import "SharingViewController.h"
#import "SharingViewControllerFactory.h"

@interface SharingViewController ()

@property (nonatomic, weak) UIActivity *activity;

@end

@implementation SharingViewController

- (instancetype)initWithSharingType:(SharingType)type attachment:(SharingAttachment *)attachment activity:(UIActivity *)activity {
    UIViewController <SharingViewControllerProtocol> *controller = [SharingViewControllerFactory viewControllerForType:type withAttachment:attachment];
    self = [super initWithRootViewController:controller];
    if (self) {
        _activity = activity;
        controller.sharingController = self;
    }
    return self;
}

- (void)finishActivity:(BOOL)success {
    NSAssert(_activity, @"Activity not exists");
    [_activity activityDidFinish:success];
}

@end
