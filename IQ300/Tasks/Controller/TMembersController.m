//
//  TMembersController.m
//  IQ300
//
//  Created by Tayphoon on 17.03.15.
//  Copyright (c) 2015 Tayphoon. All rights reserved.
//
#import <SDWebImage/UIImageView+WebCache.h>
#import <QuartzCore/CALayer.h>

#import "TMembersController.h"
#import "ContactPickerController.h"
#import "IQSession.h"
#import "ContactCell.h"
#import "IQUser.h"
#import "IQTask.h"
#import "DiscussionController.h"
#import "MessagesModel.h"
#import "IQConversation.h"

@interface TMembersController () <ContactPickerControllerDelegate> {
    UILabel * _noDataLabel;
    UsersPickerModel * _usersModel;
}

@end

@implementation TMembersController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil {
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        self.title = NSLocalizedString(@"Members", nil);

        UIImage * barImage = [[UIImage imageNamed:@"task_member_tab.png"] imageWithRenderingMode:UIImageRenderingModeAlwaysOriginal];
        
        float imageOffset = 6;
        self.tabBarItem = [[UITabBarItem alloc] initWithTitle:nil image:barImage selectedImage:barImage];
        self.tabBarItem.imageInsets = UIEdgeInsetsMake(imageOffset, 0, -imageOffset, 0);
        
        _usersModel =  [[UsersPickerModel alloc] init];
        self.model = _usersModel;
    }
    return self;
}

- (void)setTask:(IQTask *)task {
    _task = task;
    
    [self.model setValue:@[_task.executor, _task.customer] forKey:@"_usersInternal"];
    
    if(self.isViewLoaded) {
        [self.tableView reloadData];
    }
}

- (void)viewDidLoad {
    [super viewDidLoad];
    self.view.backgroundColor = [UIColor whiteColor];
    self.tableView.tableFooterView = [UIView new];
    
    _noDataLabel = [[UILabel alloc] init];
    [_noDataLabel setFont:[UIFont fontWithName:IQ_HELVETICA size:15]];
    [_noDataLabel setTextColor:[UIColor colorWithHexInt:0xb3b3b3]];
    _noDataLabel.textAlignment = NSTextAlignmentCenter;
    _noDataLabel.backgroundColor = [UIColor clearColor];
    _noDataLabel.numberOfLines = 0;
    _noDataLabel.lineBreakMode = NSLineBreakByWordWrapping;
    [_noDataLabel setHidden:YES];
    [_noDataLabel setText:NSLocalizedString(@"No contacts", nil)];
    [self.view addSubview:_noDataLabel];
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    
    UIBarButtonItem * addButton = [[UIBarButtonItem alloc] initWithImage:[UIImage imageNamed:@"white_add_ico.png"]
                                                                    style:UIBarButtonItemStylePlain
                                                                   target:self
                                                                   action:@selector(addButtonAction:)];
    self.parentViewController.navigationItem.rightBarButtonItem = addButton;
    
    if([IQSession defaultSession]) {
        [self.tableView reloadData];
    }
}

#pragma mark - UITableView DataSource

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    ContactCell * cell = [tableView dequeueReusableCellWithIdentifier:[self.model reuseIdentifierForIndexPath:indexPath]];
    
    if (!cell) {
        cell = [self.model createCellForIndexPath:indexPath];
    }
    
    IQUser * user = [self.model itemAtIndexPath:indexPath];
    
    cell.textLabel.text = user.displayName;
    cell.detailTextLabel.text = user.email;
    
    return cell;
}

#pragma mark - UITableView Delegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    IQUser * user = [self.model itemAtIndexPath:indexPath];
    NSString * companionName = user.displayName;
    NSNumber * userId = user.userId;
    [MessagesModel createConversationWithRecipientId:userId
                                          completion:^(IQConversation * conv, NSError *error) {
                                              if(!error) {
                                                  DiscussionModel * model = [[DiscussionModel alloc] initWithDiscussion:conv.discussion];
                                                  model.companionId = userId;
                                                  
                                                  DiscussionController * controller = [[DiscussionController alloc] init];
                                                  controller.hidesBottomBarWhenPushed = YES;
                                                  controller.model = model;
                                                  controller.title = companionName;
                                                  
                                                  [MessagesModel markConversationAsRead:conv completion:nil];
                                                  [self.navigationController pushViewController:controller animated:YES];
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

#pragma mark - ContactPickerController Delegate

- (void)contactPickerController:(ContactPickerController *)picker didPickUser:(IQUser *)user {
    [self.navigationController popViewControllerAnimated:YES];
}

#pragma mark - Private methods

- (void)addButtonAction:(UIButton*)sender {
    ContactPickerController * controller = [[ContactPickerController alloc] init];
    controller.model = [[UsersModel alloc] init];
    controller.delegate = self;
    [self.navigationController pushViewController:controller animated:YES];
}

- (void)updateNoDataLabelVisibility {
    [_noDataLabel setHidden:([self.model numberOfItemsInSection:0] > 0)];
}

@end
