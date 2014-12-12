//
//  CreateConversationController.m
//  IQ300
//
//  Created by Tayphoon on 09.12.14.
//  Copyright (c) 2014 Tayphoon. All rights reserved.
//
#import <SVPullToRefresh/UIScrollView+SVPullToRefresh.h>
#import <MMDrawerController/UIViewController+MMDrawerController.h>

#import "CreateConversationController.h"
#import "CreateConversationView.h"
#import "IQSession.h"
#import "ContactCell.h"
#import "IQContact.h"
#import "MessagesModel.h"
#import "IQConversation.h"
#import "DiscussionController.h"
#import "DispatchAfterExecution.h"

#define DISPATCH_DELAY 0.7

@interface CreateConversationController() {
    CreateConversationView * _mainView;
    dispatch_after_block _cancelBlock;
}

@end

@implementation CreateConversationController

- (void)loadView {
    _mainView = [[CreateConversationView alloc] init];
    self.view = _mainView;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    [_mainView.backButton addTarget:self
                             action:@selector(backButtonAction:)
                   forControlEvents:UIControlEventTouchUpInside];

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
}

- (UITableView*)tableView {
    return _mainView.tableView;
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    if([IQSession defaultSession]) {
        [self reloadModel];
    }
}

#pragma mark - UITableView DataSource

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    ContactCell * cell = [tableView dequeueReusableCellWithIdentifier:[self.model reuseIdentifierForIndexPath:indexPath]];
    
    if (!cell) {
        cell = [self.model createCellForIndexPath:indexPath];
    }
    
    id contact = [self.model itemAtIndexPath:indexPath];
    cell.item = contact;
    
    return cell;
}

#pragma mark - UITableView Delegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    IQContact * contact = [self.model itemAtIndexPath:indexPath];
    NSString * companionName = contact.user.displayName;
    NSNumber * userId = contact.user.userId;
    [MessagesModel createConversationWithRecipientId:userId
                                          completion:^(IQConversation * conv, NSError *error) {
                                              if(!error) {
                                                  DiscussionModel * model = [[DiscussionModel alloc] initWithDiscussion:conv.discussion];
                                                  model.companionId = userId;
                                                  
                                                  DiscussionController * controller = [[DiscussionController alloc] init];
                                                  controller.title = NSLocalizedString(@"Messages", nil);
                                                  controller.model = model;
                                                  controller.companionName = companionName;

                                                  [MessagesModel markConversationAsRead:conv completion:nil];
                                                  
                                                  NSArray * newStack = @[[self.navigationController.viewControllers firstObject],
                                                                         controller];
                                                  [self.navigationController setViewControllers:newStack animated:YES];
                                              }
                                          }];
}

#pragma mark - IQTableModel Delegate

- (void)modelDidChangeContent:(id<IQTableModel>)model {
    [super modelDidChangeContent:model];
    [self updateNoDataLabelVisibility];
}

- (void)modelDidChanged:(id<IQTableModel>)model {
    [super modelDidChanged:model];
    [self updateNoDataLabelVisibility];
}

#pragma mark - TextField Delegate

- (void)textFieldDidChange:(UITextField *)textField {
    [self filterWithText:textField.text];
}

#pragma mark - Private methods

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
    [self.model updateModelSourceControllerWithCompletion:compleationBlock];
    
    _cancelBlock = dispatch_after_delay(DISPATCH_DELAY, dispatch_get_main_queue(), ^{
        [self.model reloadFirstPartWithCompletion:compleationBlock];
    });
}

@end
