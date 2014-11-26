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

BOOL NSStringIsValidEmail(NSString * checkString) {
    BOOL stricterFilter = NO;
    NSString *stricterFilterString = @"[A-Z0-9a-z\\._%+-]+@([A-Za-z0-9-]+\\.)+[A-Za-z]{2,4}";
    NSString *laxString = @".+@([A-Za-z0-9-]+\\.)+[A-Za-z]{2}[A-Za-z]*";
    NSString *emailRegex = stricterFilter ? stricterFilterString : laxString;
    NSPredicate *emailTest = [NSPredicate predicateWithFormat:@"SELF MATCHES %@", emailRegex];
    return [emailTest evaluateWithObject:checkString];
}

@interface LoginController() {
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
        [IQService serviceWithURL:SERVICE_URL andSession:[IQSession defaultSession]];
        [[IQService sharedService] loginWithEmail:_loginView.emailTextField.text
                                         password:_loginView.passwordTextField.text
                                          handler:^(BOOL success, NSData *responseData, NSError *error) {
                                              if(success) {
                                                  [self continueLoginProccess];
                                              }
                                              else {
                                                  [self showErrorMessage:@"Wrong credentials"];
                                              }
                                          }];
        [[UIApplication sharedApplication] setStatusBarHidden:NO];
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
            [[NSNotificationCenter defaultCenter] postNotificationName:AccountDidChangedNotification
                                                                object:nil];
            [self dismissViewControllerAnimated:YES completion:nil];
        }
    }];
}

@end
