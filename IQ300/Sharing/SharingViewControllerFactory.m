//
//  SharingViewControllerFactory.m
//  IQ300
//
//  Created by Vladislav Grigoryev on 02/02/16.
//  Copyright © 2016 Tayphoon. All rights reserved.
//

#import "SharingViewControllerFactory.h"
#import "SharingMessagesController.h"

@implementation SharingViewControllerFactory

static NSDictionary *sharingControllersClasses;

+ (void)initialize {
    sharingControllersClasses =   @{
                                    @(SharingTypeMessages) : [SharingMessagesController class]
                                    
                                    };
}

+ (UIViewController<SharingViewControllerProtocol> *)viewControllerForType:(SharingType)type withAttachment:(SharingAttachment *)attachemnt{
    Class sharingViewControllerClass = [sharingControllersClasses objectForKey:@(type)];
    NSAssert(sharingControllersClasses, @"Not specified class type");
    return [[sharingViewControllerClass alloc] initWithAttachment:attachemnt];
}

@end
