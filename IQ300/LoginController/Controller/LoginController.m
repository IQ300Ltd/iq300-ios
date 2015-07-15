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
#import "IQValidationHelper.h"
#import "RegistrationController.h"

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
    
    [_loginView.enterButton addTarget:self
                               action:@selector(enterButtonAction:)
                     forControlEvents:UIControlEventTouchUpInside];
    [_loginView.registryButton addTarget:self
                                  action:@selector(registryButtonAction:)
                        forControlEvents:UIControlEventTouchUpInside];
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
                                                    else if(IsNetworUnreachableError(error) || ![IQService sharedService].isServiceReachable) {
                                                        [self showErrorMessage:INTERNET_UNREACHABLE_MESSAGE];
                                                    }
                                                    else {
                                                        [self showErrorMessage:@"Wrong credentials"];
                                                    }
                                                }];
    }
}

- (void)registryButtonAction:(UIButton*)sender {
    RegistrationController * controller = [[RegistrationController alloc] init];
    [self.navigationController pushViewController:controller animated:YES];
    
    [GAIService sendEventForCategory:GAICommonEventCategory
                              action:@"event_action_common_registration"];
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
            [GAIService sendEventForCategory:GAICommonEventCategory
                                      action:@"event_action_common_login"];
            
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
