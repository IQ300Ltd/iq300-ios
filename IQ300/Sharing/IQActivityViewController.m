//
//  IQActivityViewController.m
//  IQ300
//
//  Created by Vladislav Grigoryev on 1/28/16.
//  Copyright © 2016 Tayphoon. All rights reserved.
//

#import "IQActivityViewController.h"
#import "IQOpenInActivity.h"

@interface IQActivityViewController () <IQOpenInActivityDelegate>

@end

@implementation IQActivityViewController

- (instancetype)initWithActivityItem:(id)activityItem applicationActivities:(NSArray<__kindof UIActivity *> *)applicationActivities {
    IQOpenInActivity *openInActivity = [[IQOpenInActivity alloc] init];
    
    NSArray *activities = applicationActivities ? [applicationActivities arrayByAddingObjectsFromArray:@[openInActivity]] : @[openInActivity];
    
    self = [super initWithActivityItems:@[activityItem] applicationActivities:activities];
    if (self) {
        openInActivity.delegate = self;
        
    }
    return self;
}

- (BOOL)openInActivity:(IQOpenInActivity * _Nonnull)activity didCreateDocumentInteractionController:(UIDocumentInteractionController * _Nonnull)controller {
    if (_delegate && [_delegate willShowDocumentInteractionController]) {
        
        if (SYSTEM_VERSION_GREATER_THAN_OR_EQUAL_TO(@"8.0")) {
            UIActivityViewControllerCompletionWithItemsHandler handler = self.completionWithItemsHandler;
            
            __weak typeof(self) weakSelf = self;
            self.completionWithItemsHandler = ^(NSString * __nullable activityType, BOOL completed, NSArray * __nullable returnedItems, NSError * __nullable activityError) {
                if (weakSelf.delegate) {
                    [weakSelf.delegate shouldShowDocumentInteractionController:controller fromRect:weakSelf.documentInteractionControllerRect];
                }
                if (handler) {
                    handler(activityType, completed, returnedItems, activityError);
                }
            };
        }
        else {
            UIActivityViewControllerCompletionHandler handler = self.completionHandler;
            
            __weak typeof(self) weakSelf = self;
            self.completionHandler = ^ (NSString * __nullable activityType, BOOL completed) {
                if (weakSelf.delegate) {
                    [weakSelf.delegate shouldShowDocumentInteractionController:controller fromRect:weakSelf.documentInteractionControllerRect];
                }
                if (handler) {
                    handler(activityType, completed);
                }
            };
        }
        
        return YES;
    }
    return NO;
}

@end
