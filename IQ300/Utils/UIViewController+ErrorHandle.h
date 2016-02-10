//
//  UIViewController+ErrorHandle.h
//  IQ300
//
//  Created by Vladislav Grigoryev on 10/02/16.
//  Copyright © 2016 Tayphoon. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface UIViewController (ErrorHandle)

- (void)showHudWindowWithText:(NSString*)message;

- (void)showErrorAlertWithMessage:(NSString*)message;

- (void)proccessServiceError:(NSError*)error;

@end
