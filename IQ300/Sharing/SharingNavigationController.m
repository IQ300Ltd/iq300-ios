//
//  SharingViewController.m
//  IQ300
//
//  Created by Vladislav Grigoryev on 2/1/16.
//  Copyright © 2016 Tayphoon. All rights reserved.
//

#import "SharingNavigationController.h"
#import "SharingMessagesController.h"

@implementation SharingNavigationController

- (instancetype)initWithSharingType:(SharingType)type attachments:(IQAttachment *)attachment {
    static NSDictionary *sharingControllersClasses = nil;
    static dispatch_once_t onceToken;
    
    dispatch_once(&onceToken, ^{
        sharingControllersClasses =   @{
                                        @(SharingTypeMessages) : [SharingMessagesController class]
                                        
                                        };
    });
    
    Class sharingViewControllerClass = [sharingControllersClasses objectForKey:@(type)];
    NSAssert(sharingControllersClasses, @"Not specified class type");

    UIViewController<SharingViewControllerProtocol> *sharingViewController = [[sharingViewControllerClass alloc] initWithAttachment:attachment];
  
    self = [super initWithRootViewController:sharingViewController];
    
    if (self) {
        
    }
    
    return self;
}

@end
