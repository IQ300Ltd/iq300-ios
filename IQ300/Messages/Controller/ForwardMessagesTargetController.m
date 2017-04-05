//
//  ForwardMessagesTargetController.m
//  IQ300
//
//  Created by Viktor Shabanov on 05.04.17.
//  Copyright © 2017 Tayphoon. All rights reserved.
//

#import "ForwardMessagesTargetController.h"
#import "MessagesView.h"
#import "UIViewController+LeftMenu.h"
#import "IQDrawerController.h"
#import "IQConversation.h"
#import "IQService+Messages.h"
#import "DiscussionModel.h"
#import "DiscussionController.h"
#import "ContactPickerController.h"
#import "ContactsModel.h"
#import "IQDiscussion.h"
#import "IQContact.h"

@interface ForwardMessagesTargetController () {
    //MessagesView *_messagesView;
}

@end

@implementation ForwardMessagesTargetController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil {
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        self.title = NSLocalizedString(@"Forward message", nil);

        self.tabBarItem = nil;
    }
    
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    [[NSNotificationCenter defaultCenter] removeObserver:self
                                                    name:CountersDidChangedNotification
                                                  object:nil];
    
    UIBarButtonItem * rightBarButton = [[UIBarButtonItem alloc] initWithImage:[UIImage imageNamed:@"add_user_icon.png"]
                                                                        style:UIBarButtonItemStylePlain
                                                                       target:self
                                                                       action:@selector(rightBarButtonAction:)];
    self.navigationItem.rightBarButtonItem = rightBarButton;
    
    UIBarButtonItem *backBarButton = [[UIBarButtonItem alloc] initWithImage:[UIImage imageNamed:@"backWhiteArrow.png"]
                                                                      style:UIBarButtonItemStylePlain
                                                                     target:self
                                                                     action:@selector(backButtonAction:)];
    self.navigationItem.leftBarButtonItem = backBarButton;
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    
}

#pragma mark - Override parent methods

- (void)backButtonAction:(UIButton *)sender {
    [_messagesView.searchBar resignFirstResponder];
    [self.navigationController popViewControllerAnimated:YES];
}

- (void)rightBarButtonAction:(UIButton *)sender {
    ContactsModel *model = [[ContactsModel alloc] init];
    model.allowsMultipleSelection = NO;
    model.allowsDeselection = YES;
    
    ContactPickerController * controller = [[ContactPickerController alloc] init];
    controller.hidesBottomBarWhenPushed = YES;
    controller.model = model;
    controller.delegate = self;
    [self.navigationController pushViewController:controller animated:YES];
}

- (BOOL)isLeftMenuEnabled {
    return NO;
}

- (void)updateControllerTitle {
    
}

#pragma mark - UITableView Delegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    __weak typeof(self) weakSelf = self;
    [self showForwardСonfirmationWithSuccessBlock:^{
        IQConversation *conversation = [self.model itemAtIndexPath:indexPath];
        [weakSelf forwardMessageToConversation:conversation];
    }];
}

#pragma mark - IQSelectionControllerDelegate

- (void)selectionControllerController:(IQSelectionController *)controller didSelectItem:(IQContact *)item {
    __weak typeof(self) weakSelf = self;
    [self showForwardСonfirmationWithSuccessBlock:^{
        [weakSelf forwardMessageToContact:item];
    }];
}

#pragma mark - Private

- (void)forwardMessageToConversation:(IQConversation *)conversation {
    __weak typeof(self) weakSelf = self;
    [[IQService sharedService] forwardCommentWithId:self.forwardingComment.commentId
                                   fromDiscussionId:self.forwardingComment.discussionId
                                   toConversationId:conversation.conversationId
                                            handler:^(BOOL success, IQConversation *targetConversation, NSData *responseData, NSError *error) {
                                                if (success) {
                                                    [weakSelf moveToTargetConversation:targetConversation];
                                                }
                                                else {
                                                    [_messagesView.searchBar resignFirstResponder];
                                                    [weakSelf.navigationController popViewControllerAnimated:YES];
                                                }
                                            }];
}

- (void)forwardMessageToContact:(IQContact *)contact {
    __weak typeof(self) weakSelf = self;
    [[IQService sharedService] forwardCommentWithId:self.forwardingComment.commentId
                                   fromDiscussionId:self.forwardingComment.discussionId
                                        toContactId:contact.contactId
                                            handler:^(BOOL success, IQConversation *targetConversation, NSData *responseData, NSError *error) {
                                                if (success) {
                                                    [weakSelf moveToTargetConversation:targetConversation];
                                                }
                                                else {
                                                    [_messagesView.searchBar resignFirstResponder];
                                                    [weakSelf.navigationController popViewControllerAnimated:YES];
                                                }
                                            }];
}

- (void)moveToTargetConversation:(IQConversation *)targetConversation {
    DiscussionModel * model = [[DiscussionModel alloc] initWithDiscussion:targetConversation.discussion];
    
    DiscussionController * controller = [[DiscussionController alloc] init];
    controller.hidesBottomBarWhenPushed = YES;
    controller.title = targetConversation.title;
    controller.model = model;
    
    NSArray *viewControllers = [self showableViewControllersStackFromCurrentStack:self.navigationController.viewControllers
                                                          forTargetViewController:controller];
    
    [self.navigationController setViewControllers:viewControllers animated:YES];
    
    __weak typeof(self) weakSelf = self;
    [MessagesModel markConversationAsRead:targetConversation completion:^(NSError *error) {
        [weakSelf updateGlobalCounter];
    }];
    
    [MessagesModel reloadConversation:targetConversation completion:nil];
}

- (NSArray *)showableViewControllersStackFromCurrentStack:(NSArray *)currentStack
                                  forTargetViewController:(UIViewController *)viewController {
    return @[[currentStack firstObject], viewController];
}

- (NSArray *)viewControllersStackToPresetTargetForwardConversation {
    return @[
             [self.navigationController.viewControllers firstObject]
             ];
}

- (void)showForwardСonfirmationWithSuccessBlock:(void (^)(void))successBlock {
    __weak typeof(self) weakSelf = self;
    [UIAlertView showWithTitle:NSLocalizedString(@"Attention", nil)
                       message:NSLocalizedString(@"Do you really want to forward the message?", nil)
             cancelButtonTitle:NSLocalizedString(@"Cancel", nil)
             otherButtonTitles:@[NSLocalizedString(@"Yes", nil)]
                      tapBlock:^(UIAlertView *alertView, NSInteger buttonIndex) {
                          if (buttonIndex) {
                              if (successBlock) {
                                  successBlock();
                              }
                          }
                          else {
                              [_messagesView.searchBar resignFirstResponder];
                              [weakSelf.navigationController popViewControllerAnimated:YES];
                          }
                      }];
}

@end
