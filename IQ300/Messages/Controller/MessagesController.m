//
//  MessagesController.m
//  IQ300
//
//  Created by Tayphoon on 02.12.14.
//  Copyright (c) 2014 Tayphoon. All rights reserved.
//
#import <SVPullToRefresh/UIScrollView+SVPullToRefresh.h>
#import <MMDrawerController/UIViewController+MMDrawerController.h>

#import "UIViewController+LeftMenu.h"
#import "IQSession.h"

#import "MessagesController.h"
#import "MessagesView.h"
#import "ConversationCell.h"
#import "IQConversation.h"

#import "DiscussionController.h"

@interface MessagesController() {
    MessagesView * _messagesView;
}

@end

@implementation MessagesController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil {
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        self.title = NSLocalizedString(@"Messages", nil);
        UIImage * barImage = [[UIImage imageNamed:@"messages_tab.png"] imageWithRenderingMode:UIImageRenderingModeAlwaysOriginal];
        UIImage * barImageSel = [[UIImage imageNamed:@"messgaes_tab_sel.png"] imageWithRenderingMode:UIImageRenderingModeAlwaysOriginal];
        
        float imageOffset = 6;
        self.tabBarItem = [[UITabBarItem alloc] initWithTitle:nil image:barImage selectedImage:barImageSel];
        self.tabBarItem.imageInsets = UIEdgeInsetsMake(imageOffset, 0, -imageOffset, 0);
        self.model = [[MessagesModel alloc] init];
    }
    return self;
}

- (void)loadView {
    _messagesView = [[MessagesView alloc] init];
    self.view = _messagesView;
}

- (UITableView*)tableView {
    return _messagesView.tableView;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    self.view.backgroundColor = [UIColor whiteColor];
    
    _messagesView.searchBar.delegate = (id<UITextFieldDelegate>)self;
    
    __weak typeof(self) weakSelf = self;
    [self.tableView
     addPullToRefreshWithActionHandler:^{
         [weakSelf.model updateModelWithCompletion:^(NSError *error) {
             [weakSelf.tableView.pullToRefreshView stopAnimating];
         }];
     }
     position:SVPullToRefreshPositionBottom];
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    
    UIBarButtonItem * rightBarButton = [[UIBarButtonItem alloc] initWithImage:[UIImage imageNamed:@"createNewMessage.png"]
                                                                        style:UIBarButtonItemStylePlain
                                                                       target:self action:@selector(createNewAction:)];
    self.navigationItem.rightBarButtonItem = rightBarButton;

    
    [self.leftMenuController setModel:nil];
    [self.leftMenuController reloadMenuWithCompletion:nil];
    
    if([IQSession defaultSession]) {
        [self reloadModel];
    }
    
    [self.model setSubscribedToSystemWakeNotifications:YES];
}

- (void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
    [self.model setSubscribedToSystemWakeNotifications:NO];
}

#pragma mark - UITableView DataSource

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    ConversationCell * cell = [tableView dequeueReusableCellWithIdentifier:[self.model reuseIdentifierForIndexPath:indexPath]];
    
    if (!cell) {
        cell = [self.model createCellForIndexPath:indexPath];
    }
    
    IQConversation * conversation = [self.model itemAtIndexPath:indexPath];
    cell.item = conversation;
    
    return cell;
}

#pragma mark - UITableView Delegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    ConversationCell * cell = (ConversationCell*)[tableView cellForRowAtIndexPath:indexPath];
    IQConversation * conver = [self.model itemAtIndexPath:indexPath];
    DiscussionModel * model = [[DiscussionModel alloc] initWithDiscussion:conver.discussion];
    
    DiscussionController * controller = [[DiscussionController alloc] init];
    controller.title = NSLocalizedString(@"Messages", nil);
    controller.model = model;
    controller.companionName = cell.companionName;
    [self.navigationController pushViewController:controller animated:YES];
    
    [self.model markConversationAsReadAtIndexPath:indexPath completion:nil];
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

#pragma mark - Menu Responder Delegate

- (void)menuController:(MenuViewController*)controller didSelectMenuItemAtIndexPath:(NSIndexPath*)indexPath {
    self.model.loadUnreadOnly = (indexPath.row == 1);
    [self reloadModel];
    [self.mm_drawerController toggleDrawerSide:MMDrawerSideLeft animated:YES completion:nil];
}

- (BOOL)textFieldShouldReturn:(UITextField *)textField {
    [textField resignFirstResponder];
    return YES;
}

#pragma mark - Private methods

- (void)createNewAction:(id)sender {
    
}

- (void)reloadModel {
    [self.model reloadModelWithCompletion:^(NSError *error) {
        if(!error) {
            [self.tableView reloadData];
            if([self.model numberOfItemsInSection:0] > 0) {
                [_messagesView.noDataLabel setHidden:YES];
                [self.tableView scrollToRowAtIndexPath:[NSIndexPath indexPathForRow:0 inSection:0]
                                      atScrollPosition:UITableViewScrollPositionTop
                                              animated:NO];
            }
            else {
                [_messagesView.noDataLabel setHidden:NO];
                [self.model updateModelWithCompletion:^(NSError *error) {
                    if([self.model numberOfItemsInSection:0] > 0) {
                        [_messagesView.noDataLabel setHidden:YES];
                    }
                }];
            }
        }
    }];
}

- (void)updateNoDataLabelVisibility {
    [_messagesView.noDataLabel setHidden:([self.model numberOfItemsInSection:0] > 0)];
}

- (void)modelCountersDidChanged:(id<IQTableModel>)model {
//    _menuModel.totalItemsCount = self.model.totalItemsCount;
//    _menuModel.unreadItemsCount = self.model.unreadItemsCount;
}

@end
