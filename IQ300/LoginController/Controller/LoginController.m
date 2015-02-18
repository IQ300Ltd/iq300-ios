//
//  LoginController.m
//  IQ300
//
//  Created by Tayphoon on 17.11.14.
//  Copyright (c) 2014 Tayphoon. All rights reserved.
//

#import "LoginController.h"
#import "LoginView.h"
#import "IQService.h"
#import "IQUser.h"
#import "IQNotificationCenter.h"
#import "AppDelegate.h"
#import "DeviceToken.h"

BOOL NSStringIsValidEmail(NSString * checkString) {
    BOOL stricterFilter = NO;
    NSString *stricterFilterString = @"[A-Z0-9a-z\\._%+-]+@([A-Za-z0-9-]+\\.)+[A-Za-z]{2,4}";
    NSString *laxString = @".+@([A-Za-z0-9-]+\\.)+[A-Za-z]{2}[A-Za-z]*";
    NSString *emailRegex = stricterFilter ? stricterFilterString : laxString;
    NSPredicate *emailTest = [NSPredicate predicateWithFormat:@"SELF MATCHES %@", emailRegex];
    return [emailTest evaluateWithObject:checkString];
}

@interface LoginController() <UITextFieldDelegate> {
    LoginView * _loginView;
}

@end

@implementation LoginController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil {
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    
    return self;
}

- (void)loadView {
    _loginView = [[LoginView alloc] init];
    self.view = _loginView;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    _loginView.emailTextField.delegate = self;
    _loginView.passwordTextField.delegate = self;
    
    [_loginView.enterButton addTarget:self action:@selector(enterButtonAction:) forControlEvents:UIControlEventTouchUpInside];
    [_loginView.registryButton addTarget:self action:@selector(registryButtonAction:) forControlEvents:UIControlEventTouchUpInside];
    [_loginView.restorePassButton addTarget:self action:@selector(restorePassButtonAction:) forControlEvents:UIControlEventTouchUpInside];
}

- (void)enterButtonAction:(UIButton*)sender {
    if([_loginView.emailTextField.text length] == 0 || [_loginView.passwordTextField.text length] == 0) {
        [self showErrorMessage:@"Email and password fields is required"];
    }
    else if(!NSStringIsValidEmail(_loginView.emailTextField.text)) {
        [self showErrorMessage:@"Email address is invalid"];
    }
    else {
        [[IQService sharedService] loginWithDeviceToken:[DeviceToken uniqueIdentifier]
                                                  email:_loginView.emailTextField.text
                                               password:_loginView.passwordTextField.text
                                                handler:^(BOOL success, NSData *responseData, NSError *error) {
                                                    if(success) {
                                                        [self continueLoginProccess];
                                                    }
                                                    else if([IQService sharedService].serviceReachabilityStatus == TCServicekReachabilityStatusNotReachable) {
                                                        [self showErrorMessage:@"Internet connection is unavailable"];
                                                    }
                                                    else {
                                                        [self showErrorMessage:@"Wrong credentials"];
                                                    }
                                                }];
    }
}

- (void)registryButtonAction:(UIButton*)sender {
    [[UIApplication sharedApplication] openURL:[NSURL URLWithString:SERVICE_REGISTRATION_URL]];
}

- (void)restorePassButtonAction:(UIButton*)sender {
    [[UIApplication sharedApplication] openURL:[NSURL URLWithString:SERVICE_RESET_PASSWORD_URL]];
}

- (void)showErrorMessage:(NSString*)errorMessage {
    _loginView.errorLabel.text = NSLocalizedString(errorMessage, nil);
}

- (void)continueLoginProccess {
    [[IQService sharedService] userInfoWithHandler:^(BOOL success, IQUser * user, NSData *responseData, NSError *error) {
        if(success) {
            [IQSession setDefaultSession:[IQService sharedService].session];
            [AppDelegate setupNotificationCenter];
            [AppDelegate registerForRemoteNotifications];
                    
            [[NSNotificationCenter defaultCenter] postNotificationName:AccountDidChangedNotification
                                                                object:nil];
            
            [self dismissViewControllerAnimated:YES completion:nil];
            [[UIApplication sharedApplication] setStatusBarHidden:NO];
        }
    }];
}

#pragma mark - TextField Delegate

- (BOOL)textFieldShouldReturn:(UITextField*)textField {
    NSInteger nextTag = textField.tag + 1;
    // Try to find next responder
    UIResponder* nextResponder = [textField.superview.superview viewWithTag:nextTag];
    if (nextResponder) {
        [nextResponder becomeFirstResponder];
    } else {
        [textField resignFirstResponder];
        if([_loginView.emailTextField.text length] > 0 && [_loginView.passwordTextField.text length] > 0) {
            [self enterButtonAction:_loginView.enterButton];
        }
    }
    return NO;
}

@end
