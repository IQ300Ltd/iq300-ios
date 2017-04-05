//
//  ForwardMessagesTargetController.m
//  IQ300
//
//  Created by Viktor Sabanov on 05.04.17.
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
    
    self.navigationItem.rightBarButtonItem = nil;
    
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

- (BOOL)isLeftMenuEnabled {
    return NO;
}

- (void)updateControllerTitle {
    
}

#pragma mark - UITableView Delegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    [UIAlertView showWithTitle:NSLocalizedString(@"Attention", nil)
                       message:NSLocalizedString(@"Do you really want to forward the message?", nil)
             cancelButtonTitle:NSLocalizedString(@"Cancel", nil)
             otherButtonTitles:@[NSLocalizedString(@"Yes", nil)]
                      tapBlock:^(UIAlertView *alertView, NSInteger buttonIndex) {
                          if (buttonIndex) {
                              IQConversation *conversation = [self.model itemAtIndexPath:indexPath];
                              [self forwardMessageToConversation:conversation];
                          }
                          else {
                              [_messagesView.searchBar resignFirstResponder];
                              [self.navigationController popViewControllerAnimated:YES];
                          }
                      }];
}

- (void)forwardMessageToConversation:(IQConversation *)conversation {
    [[IQService sharedService] forwardCommentWithId:self.forwardingComment.commentId
                                   fromDiscussionId:self.forwardingComment.discussionId
                                   toConversationId:conversation.conversationId
                                            handler:^(BOOL success, IQConversation *targetConversation, NSData *responseData, NSError *error) {
                                                if (success) {
                                                    DiscussionModel * model = [[DiscussionModel alloc] initWithDiscussion:targetConversation.discussion];
                                                    
                                                    DiscussionController * controller = [[DiscussionController alloc] init];
                                                    controller.hidesBottomBarWhenPushed = YES;
                                                    controller.title = targetConversation.title;
                                                    controller.model = model;
                                                    
                                                    [self.navigationController setViewControllers:@[[self.navigationController.viewControllers firstObject], controller] animated:YES];
                                                    
                                                    __weak typeof(self) weakSelf = self;
                                                    [MessagesModel markConversationAsRead:targetConversation completion:^(NSError *error) {
                                                        [weakSelf updateGlobalCounter];
                                                    }];
                                                    
                                                    [MessagesModel reloadConversation:targetConversation completion:nil];
                                                }
                                                else {
                                                    [_messagesView.searchBar resignFirstResponder];
                                                    [self.navigationController popViewControllerAnimated:YES];
                                                }
                                            }];
}

@end
