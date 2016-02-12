//
//  UIViewController+ErrorHandle.m
//  IQ300
//
//  Created by Vladislav Grigoryev on 10/02/16.
//  Copyright © 2016 Tayphoon. All rights reserved.
//

#import "UIViewController+ErrorHandle.h"
#import <MBProgressHUD/MBProgressHUD.h>
#import "IQService.h"

@implementation UIViewController (ErrorHandle)

- (void)showHudWindowWithText:(NSString *)message {
    MBProgressHUD *hud = nil;
    
    if (self.navigationController) {
        hud = [MBProgressHUD showHUDAddedTo:self.navigationController.view animated:YES];
    }
    else {
        hud = [MBProgressHUD showHUDAddedTo:self.view animated:YES];
    }
    
    // Configure for text only and offset down
    hud.mode = MBProgressHUDModeText;
    hud.detailsLabelText = message;
    hud.margin = 10.f;
    hud.removeFromSuperViewOnHide = YES;
    
    [hud hide:YES afterDelay:3];
}

- (void)showErrorAlertWithMessage:(NSString *)message {
    UIAlertView * alertView = [[UIAlertView alloc] initWithTitle:NSLocalizedString(@"Attention", nil)
                                                         message:message
                                                        delegate:nil
                                               cancelButtonTitle:@"OK"
                                               otherButtonTitles:nil];
    
    [alertView show];
}

- (void)proccessServiceError:(NSError*)error {
    if (error) {
        if (IsNetworUnreachableError(error) || ![IQService sharedService].isServiceReachable) {
            [self showHudWindowWithText:NSLocalizedString(INTERNET_UNREACHABLE_MESSAGE, nil)];
        }
        else {
            [self showErrorAlertWithMessage:error.localizedDescription];
        }
    }
}


@end
