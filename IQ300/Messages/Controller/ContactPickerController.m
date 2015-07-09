//
//  CreateConversationController.m
//  IQ300
//
//  Created by Tayphoon on 09.12.14.
//  Copyright (c) 2014 Tayphoon. All rights reserved.
//
#import <SVPullToRefresh/UIScrollView+SVPullToRefresh.h>
#import <MMDrawerController/UIViewController+MMDrawerController.h>

#import "ContactPickerController.h"
#import "ContactPickerView.h"
#import "IQSession.h"
#import "ContactCell.h"
#import "IQContact.h"
#import "MessagesModel.h"
#import "IQConversation.h"
#import "DiscussionController.h"
#import "DispatchAfterExecution.h"
#import "IQDrawerController.h"

#define DISPATCH_DELAY 0.7

@interface ContactPickerController() {
    ContactPickerView * _mainView;
    dispatch_after_block _cancelBlock;
}

@end

@implementation ContactPickerController

@dynamic model;

- (void)loadView {
    _mainView = [[ContactPickerView alloc] init];
    self.view = _mainView;
}

- (void)viewDidLoad {
    [super viewDidLoad];

    __weak typeof(self) weakSelf = self;
    [self.tableView
     addPullToRefreshWithActionHandler:^{
         [weakSelf.model updateModelWithCompletion:^(NSError *error) {
             [weakSelf.tableView.pullToRefreshView stopAnimating];
         }];
     }
     position:SVPullToRefreshPositionBottom];
    
    [_mainView.userTextField addTarget:self
                                action:@selector(textFieldDidChange:)
                      forControlEvents:UIControlEventEditingChanged];
    
    _mainView.userTextField.delegate = (id<UITextFieldDelegate>)self;
    [_mainView.clearTextFieldButton addTarget:self
                                       action:@selector(clearFilter)
                             forControlEvents:UIControlEventTouchUpInside];
}

- (UITableView*)tableView {
    return _mainView.tableView;
}

- (BOOL)isLeftMenuEnabled {
    return NO;
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    
    UIBarButtonItem * backBarButton = [[UIBarButtonItem alloc] initWithImage:[UIImage imageNamed:@"backWhiteArrow.png"]
                                                                       style:UIBarButtonItemStylePlain
                                                                      target:self
                                                                      action:@selector(backButtonAction:)];
    self.navigationItem.leftBarButtonItem = backBarButton;
    
    [self setTitle:NSLocalizedString(@"Сontacts", nil)];

    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(onKeyboardWillShow:)
                                                 name:UIKeyboardWillShowNotification
                                               object:nil];
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(onKeyboardWillHide:)
                                                 name:UIKeyboardWillHideNotification
                                               object:nil];
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(drawerDidShowNotification:)
                                                 name:IQDrawerDidShowNotification
                                               object:nil];
    
    if([IQSession defaultSession]) {
        [self reloadModel];
    }
}

- (void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
    
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

#pragma mark - UITableView DataSource

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    ContactCell * cell = [tableView dequeueReusableCellWithIdentifier:[self.model reuseIdentifierForIndexPath:indexPath]];
    
    if (!cell) {
        cell = [self.model createCellForIndexPath:indexPath];
    }
    
    IQContact * contact = [self.model itemAtIndexPath:indexPath];
    cell.item = contact.user;
    
    return cell;
}

#pragma mark - UITableView Delegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    IQContact * contact = [self.model itemAtIndexPath:indexPath];
    
    if([self.delegate respondsToSelector:@selector(contactPickerController:didPickUser:)]) {
        [self.delegate contactPickerController:self didPickUser:contact.user];
    }
}

#pragma mark - TextField Delegate

- (void)textFieldDidChange:(UITextField *)textField {
    [self filterWithText:textField.text];
}

- (BOOL)textFieldShouldReturn:(UITextField *)textField {
    [textField resignFirstResponder];
    return YES;
}

#pragma mark - Keyboard Helpers

- (void)onKeyboardWillShow:(NSNotification *)notification {
    [self makeInputViewTransitionWithDownDirection:NO notification:notification];
}

- (void)onKeyboardWillHide:(NSNotification *)notification {
    [self makeInputViewTransitionWithDownDirection:YES notification:notification];
}

#pragma mark - Private methods

- (void)makeInputViewTransitionWithDownDirection:(BOOL)down notification:(NSNotification *)notification {
    NSDictionary *userInfo = [notification userInfo];
    NSTimeInterval animationDuration;
    UIViewAnimationCurve animationCurve;
    
    [[userInfo objectForKey:UIKeyboardAnimationCurveUserInfoKey] getValue:&animationCurve];
    [[userInfo objectForKey:UIKeyboardAnimationDurationUserInfoKey] getValue:&animationDuration];
    
    CGRect keyboardRect = [[userInfo objectForKey:UIKeyboardFrameEndUserInfoKey] CGRectValue];
    
    [UIView beginAnimations:nil context:nil];
    [UIView setAnimationDuration:animationDuration];
    [UIView setAnimationCurve:animationCurve];
    
    CGFloat inset = MIN(keyboardRect.size.height, keyboardRect.size.width);
    [_mainView setTableBottomMargin:down ? 0.0f : inset];
    
    [UIView commitAnimations];
}

- (void)backButtonAction:(UIButton*)sender {
    [self.navigationController popViewControllerAnimated:YES];
}

- (void)reloadModel {
    [self.model reloadModelWithCompletion:^(NSError *error) {
        if(!error) {
            [self.tableView reloadData];
            [self updateNoDataLabelVisibility];
        }
    }];
}

- (void)updateNoDataLabelVisibility {
    [_mainView.noDataLabel setHidden:([self.model numberOfItemsInSection:0] > 0)];
}

- (void)filterWithText:(NSString *)text {
    if(_cancelBlock) {
        cancel_dispatch_after_block(_cancelBlock);
    }
    
    void(^compleationBlock)(NSError * error) = ^(NSError * error) {
        if(!error) {
            [self.tableView reloadData];
            [self updateNoDataLabelVisibility];
        }
    };
    
    [self.model setFilter:text];
    [self.model reloadModelSourceControllerWithCompletion:compleationBlock];
    
    _cancelBlock = dispatch_after_delay(DISPATCH_DELAY, dispatch_get_main_queue(), ^{
        [self.model reloadFirstPartWithCompletion:compleationBlock];
    });
}

- (void)drawerDidShowNotification:(NSNotification*)notification {
    [_mainView.userTextField resignFirstResponder];
}

- (void)clearFilter {
    _mainView.userTextField.text = nil;
    [self filterWithText:nil];
}

@end
