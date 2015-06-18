//
//  RegistrationController.m
//  IQ300
//
//  Created by Tayphoon on 17.06.15.
//  Copyright (c) 2015 Tayphoon. All rights reserved.
//

#import "RegistrationController.h"
#import "RegistrationStatusController.h"
#import "RegistrationView.h"
#import "IQService.h"

@interface RegistrationController() {
    RegistrationView * _registrationView;
    NSInteger _viewTag;
}

@end

@implementation RegistrationController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil {
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
    }
    return self;
}

- (void)loadView {
    _registrationView = [[RegistrationView alloc] init];
    self.view = _registrationView;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    [_registrationView setTextFieldDelegate:(id<UITextFieldDelegate>)self];
    [_registrationView.signupButton addTarget:self
                                       action:@selector(signupButtonAction:)
                             forControlEvents:UIControlEventTouchUpInside];
    [_registrationView.enterButton addTarget:self
                                      action:@selector(enterButtonAction:)
                            forControlEvents:UIControlEventTouchUpInside];
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(onKeyboardWillShow:)
                                                 name:UIKeyboardWillShowNotification
                                               object:nil];
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(onKeyboardWillHide:)
                                                 name:UIKeyboardWillHideNotification
                                               object:nil];
}

- (void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
    
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

#pragma mark - Keyboard Notifications

- (void)onKeyboardWillShow:(NSNotification *)notification {
    [self makeInputViewTransitionWithDownDirection:NO
                                      notification:notification];
}

- (void)onKeyboardWillHide:(NSNotification *)notification {
    [self makeInputViewTransitionWithDownDirection:YES
                                      notification:notification];
}

#pragma mark - TextField Delegate

- (BOOL)textFieldShouldBeginEditing:(UITextField *)textField {
    _viewTag = textField.superview.tag;
    [_registrationView scrollToFieldWithTag:textField.superview.tag animated:YES];
    return YES;
}

- (BOOL)textFieldShouldReturn:(UITextField*)textField {
    NSInteger nextTag = textField.superview.tag + 1;
    
    // Try to find next responder
    IQTextContainer * nextResponder = [_registrationView fieldViewWithTag:nextTag];
    if (nextResponder) {
        [nextResponder.textField becomeFirstResponder];
    } else {
        [textField resignFirstResponder];
        if([self isAllFieldsValid]) {
            [self signupButtonAction:_registrationView.signupButton];
        }
    }
    return NO;
}

#pragma mark - Private methods

- (void)makeInputViewTransitionWithDownDirection:(BOOL)down notification:(NSNotification *)notification {
    NSDictionary *userInfo = [notification userInfo];
    NSTimeInterval animationDuration;
    UIViewAnimationCurve animationCurve;
    
    [[userInfo objectForKey:UIKeyboardAnimationCurveUserInfoKey] getValue:&animationCurve];
    [[userInfo objectForKey:UIKeyboardAnimationDurationUserInfoKey] getValue:&animationDuration];
    
    CGRect keyboardRect = [[userInfo objectForKey:UIKeyboardFrameEndUserInfoKey] CGRectValue];
    CGFloat inset = MIN(keyboardRect.size.height, keyboardRect.size.width);
    
    [UIView beginAnimations:nil context:nil];
    [UIView setAnimationDuration:animationDuration];
    [UIView setAnimationCurve:animationCurve];
    
    [_registrationView setScrollViewOffset:down ? 0.0f : inset];
    if (!down) {
        [_registrationView scrollToFieldWithTag:_viewTag animated:NO];
    }
    else {
        [_registrationView scrollToFieldWithTag:-1 animated:NO];
    }

    [UIView commitAnimations];
}

- (void)signupButtonAction:(UIButton*)sender {
    if ([self isAllFieldsValid]) {
        RequestCompletionHandler handler = ^(BOOL success, NSData *responseData, NSError *error) {
            if (success) {
                NSMutableParagraphStyle * paragraphStyle = [[NSParagraphStyle defaultParagraphStyle] mutableCopy];
                [paragraphStyle setAlignment:NSTextAlignmentCenter];
                
                NSMutableDictionary * attributes = @{
                                                     NSForegroundColorAttributeName : [UIColor colorWithHexInt:0x272727],
                                                     NSFontAttributeName            : [UIFont fontWithName:IQ_HELVETICA size:18],
                                                     NSParagraphStyleAttributeName  : paragraphStyle
                                                     }.mutableCopy;
                NSString * title = [NSString stringWithFormat:@"%@\n\n", NSLocalizedString(@"Thank you for registering!", nil)];
                NSMutableAttributedString * statusMessage = [[NSMutableAttributedString alloc] initWithString:title
                                                                                                   attributes:attributes];
                
                [attributes setValue:[UIFont fontWithName:IQ_HELVETICA size:15]
                              forKey:NSFontAttributeName];
                [attributes removeObjectForKey:NSParagraphStyleAttributeName];
                
                [statusMessage appendAttributedString:[[NSAttributedString alloc] initWithString:NSLocalizedString(@"registration_status_message", nil)
                                                                                      attributes:attributes]];
                RegistrationStatusController * controller = [[RegistrationStatusController alloc] init];
                controller.statusMessage = statusMessage;
                [self.navigationController pushViewController:controller animated:YES];
            }
            else if([IQService sharedService].serviceReachabilityStatus == TCServicekReachabilityStatusNotReachable) {
                [self showErrorMessage:INTERNET_UNREACHABLE_MESSAGE];
            }
            else {
                [self showErrorMessage:error.localizedDescription];
            }
        };
        
        [[IQService sharedService] signupWithFirstName:_registrationView.nameContainer.textField.text
                                              lastName:_registrationView.surnameContainer.textField.text
                                        communityTitle:_registrationView.organizationContainer.textField.text
                                                 email:_registrationView.emailContainer.textField.text
                                              password:_registrationView.passwordContainer.textField.text
                                               handler:handler];
    }
}

- (void)enterButtonAction:(UIButton*)sender {
    [self.navigationController popViewControllerAnimated:YES];
}

- (BOOL)isAllFieldsValid {
    NSError * error = nil;
    if (![_registrationView validateFieldsWithError:&error]) {
        [self showErrorMessage:error.localizedDescription];
        return NO;
    }
    return YES;
}

- (void)showErrorMessage:(NSString*)errorMessage {
    _registrationView.errorLabel.text = NSLocalizedString(errorMessage, nil);
}

@end
